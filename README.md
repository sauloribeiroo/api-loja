# API Loja — Ruby on Rails

API REST de estudo com três recursos relacionados: **Clientes**, **Produtos** e **Pedidos**.
Projeto para apresentação de faculdade, feito manualmente (pouco scaffold) para aprender cada etapa.

---

## 1. O que precisa estar instalado

| Ferramenta | Versão sugerida | Para quê |
|---|---|---|
| Ruby | 3.4.10 | linguagem |
| Rails | 8.1.3 | framework da API |
| PostgreSQL | 17.11 | banco de dados relacional |
| Git | qualquer | versionamento + deploy |
| Postman ou Insomnia | — | testar os endpoints |

No Windows: instalar Ruby pelo **RubyInstaller (versão com Devkit)** e o **PostgreSQL** pelo instalador oficial.
Depois: `gem install rails`.

## 2. Banco de dados escolhido: PostgreSQL

Motivo:
- é relacional (chaves estrangeiras, joins, integridade referencial) — exatamente o que o relacionamento cliente → pedido → produto exige;
- é o padrão do ecossistema Rails e o único aceito por praticamente todas as plataformas de deploy gratuitas;
- SQLite serviria para rodar local, mas quebra no deploy (disco efêmero). Melhor já usar Postgres desde o início.

## 3. Modelagem

```
Cliente  1 ──── N  Pedido  1 ──── N  ItemPedido  N ──── 1  Produto
```

| Tabela | Campos principais |
|---|---|
| `clientes` | nome, email (único), telefone |
| `produtos` | nome, descricao, preco (decimal), estoque (integer) |
| `pedidos` | cliente_id (FK), status, total (decimal), data |
| `item_pedidos` | pedido_id (FK), produto_id (FK), quantidade, preco_unitario |

A tabela `item_pedidos` é a tabela de junção — é ela que permite um pedido ter vários produtos
e um produto aparecer em vários pedidos (relação N:N com dados extras: `quantidade` e `preco_unitario`).

**`item_pedidos` não é um endpoint.** São 4 tabelas, mas continuam sendo 3 recursos na API.
Os itens são enviados e devolvidos dentro do JSON do pedido:

```jsonc
// POST /pedidos
{
  "cliente_id": 1,
  "itens": [
    { "produto_id": 5, "quantidade": 2 },
    { "produto_id": 9, "quantidade": 1 }
  ]
}

// GET /pedidos/42
{
  "id": 42,
  "cliente": "Ana",
  "total": 180.00,
  "itens": [
    { "produto": "Teclado", "quantidade": 2, "preco_unitario": 75.00 },
    { "produto": "Mouse",   "quantidade": 1, "preco_unitario": 30.00 }
  ]
}
```

Guardar o `preco_unitario` no item (em vez de sempre olhar o preço atual do produto) faz o pedido
antigo manter o valor da época mesmo depois de um reajuste — é o histórico da venda.

## 4. Endpoints previstos

```
GET    /clientes           POST  /clientes
GET    /clientes/:id       PATCH /clientes/:id     DELETE /clientes/:id

GET    /produtos           POST  /produtos
GET    /produtos/:id       PATCH /produtos/:id     DELETE /produtos/:id

GET    /pedidos            POST  /pedidos          (cria o pedido com seus itens)
GET    /pedidos/:id        PATCH /pedidos/:id      DELETE /pedidos/:id
GET    /clientes/:id/pedidos   (pedidos de um cliente — rota aninhada)
```

Todas retornam JSON e os códigos HTTP corretos (200, 201, 404, 422).

## 5. Roteiro de construção (ordem de estudo)

1. Criar o projeto: `rails new api-loja --api --database=postgresql`
2. Entender a estrutura de pastas do Rails (MVC sem o V, já que é API)
3. Configurar `config/database.yml` e rodar `rails db:create`
4. Migrations: criar as 4 tabelas, uma de cada vez, com FKs
5. Models: `has_many`, `belongs_to`, `validates`
6. Controllers: os 5 métodos REST (index, show, create, update, destroy) e strong parameters
7. Rotas: `resources` e rotas aninhadas em `config/routes.rb`
8. Serialização do JSON (o que a API devolve e o que esconde)
9. Regras de negócio do pedido (ver seção abaixo)
10. Seeds (`db/seeds.rb`) com dados de exemplo para a apresentação
11. Testes manuais no Postman
12. Deploy

## 5.1. Regras de negócio do pedido

A API **calcula**, ela não recebe valores prontos. No `POST /pedidos` chegam apenas
`cliente_id`, `produto_id` e `quantidade` — nenhum preço vem do cliente (senão daria
para enviar `preco: 0.01`).

Ao criar um pedido, a API:

1. busca cada produto no banco e copia o **preço atual** para o `preco_unitario` do item;
2. calcula o subtotal do item: `preco_unitario × quantidade`;
3. soma os subtotais e grava em `pedidos.total`;
4. baixa o `estoque` de cada produto.

```ruby
class Pedido < ApplicationRecord
  belongs_to :cliente
  has_many :itens, class_name: "ItemPedido"

  def calcular_total
    itens.sum { |item| item.preco_unitario * item.quantidade }
  end
end
```

**Por que guardar o preço no item:** congela o valor da venda. Se o produto for reajustado
depois, o pedido antigo mantém o preço da época — o histórico não é reescrito.

**Total: coluna ou cálculo na hora?** Guardamos na coluna `total` e recalculamos sempre que
os itens mudarem. É mais rápido e é o que sistemas reais fazem; o risco é o valor
dessincronizar se alguém alterar itens sem recalcular — por isso o recálculo fica num
callback do model, não espalhado pelo controller.

**Validações:**

- estoque insuficiente → `422 Unprocessable Entity`, e o pedido **não** é criado
- `quantidade` deve ser maior que zero
- pedido sem nenhum item é inválido
- a criação inteira roda dentro de uma **transação**: se um item falhar, nada é gravado
  pela metade (all or nothing)

## 6. Deploy

Opções gratuitas/baratas, em ordem de facilidade:

1. **Render** — mais simples: conecta no repositório do GitHub, cria um Postgres gerenciado junto e faz deploy automático a cada push. Recomendado para a apresentação.
2. **Fly.io** — usa Docker, um pouco mais técnico, mas o Rails 8 já gera o `Dockerfile` pronto.
3. **Railway** — parecido com o Render.

O que será necessário em qualquer uma delas:
- repositório no GitHub;
- variável `DATABASE_URL` (a plataforma fornece);
- `RAILS_MASTER_KEY` (está em `config/master.key`, que **não** vai para o Git);
- rodar `rails db:migrate` e `rails db:seed` no deploy.

## 7. Para a apresentação

- Diagrama do banco (as 4 tabelas e os relacionamentos)
- Coleção do Postman apontando para a URL de produção
- Demonstrar: criar cliente → criar produtos → criar pedido com itens → consultar o pedido pronto com total calculado

---

## Guias

- [Acessando o banco pelo pgAdmin](docs/banco-de-dados.md) — conectar, ver as tabelas,
  consultas SQL úteis e como gerar o diagrama (ERD) para a apresentação
- [Deploy no Render](docs/deploy-render.md) — passo a passo completo, variáveis de
  ambiente e o que fazer quando falha

## Como rodar localmente

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

A API sobe em `http://localhost:3000`. Rodar os testes: `bin/rails test`.

## Status

- [x] Ambiente instalado (Ruby 3.4, Rails 8.1, PostgreSQL 17)
- [x] Projeto criado
- [x] Migrations e models (clientes, produtos, pedidos, item_pedidos)
- [x] Controllers e rotas (incluindo a rota aninhada `/clientes/:id/pedidos`)
- [x] Regras de negócio (cálculo do total, baixa de estoque, transação)
- [x] Seeds
- [x] Testes automatizados (26 testes)
- [ ] Deploy no Render
- [ ] Coleção do Postman
- [ ] Diagrama para a apresentação
