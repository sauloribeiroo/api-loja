# Guia: acessando o banco pelo pgAdmin

O pgAdmin é a interface gráfica do PostgreSQL. Ele foi instalado junto com o
banco. Serve para **ver** o que a aplicação criou — não para criar tabelas na
mão (isso é papel das migrations).

## 1. Abrir e conectar

1. Menu Iniciar → procure por **pgAdmin 4**
2. Na primeira vez ele pede para criar uma **senha mestra**. Essa senha é só do
   pgAdmin, para proteger as conexões salvas. Pode ser qualquer uma — anote.
3. No painel esquerdo, expanda **Servers**
4. Clique em **PostgreSQL 17**. Ele vai pedir a senha do banco:

   | Campo | Valor |
   |---|---|
   | Usuário | `postgres` |
   | Senha | `postgres` |

   Marque *Save password* para não digitar toda vez.

> Se **Servers** estiver vazio, crie a conexão manualmente:
> botão direito em Servers → *Register* → *Server*
> - Aba **General** → Name: `Local`
> - Aba **Connection** → Host: `localhost`, Port: `5432`,
>   Username: `postgres`, Password: `postgres`

## 2. Encontrar as tabelas

Navegue nesta ordem:

```
Servers
 └── PostgreSQL 17
      └── Databases
           └── api_loja_development      ← o banco da aplicação
                └── Schemas
                     └── public
                          └── Tables     ← aqui estão as 4 tabelas
```

Você vai encontrar:

| Tabela | O que é |
|---|---|
| `clientes` | seus clientes |
| `produtos` | seus produtos |
| `pedidos` | os pedidos, com `cliente_id` e `total` |
| `item_pedidos` | os itens de cada pedido |
| `schema_migrations` | controle interno do Rails: quais migrations já rodaram |
| `ar_internal_metadata` | controle interno do Rails: qual ambiente é este banco |

As duas últimas são do Rails, não do seu modelo. Não mexa nelas.

## 3. Ver os dados

Botão direito numa tabela → **View/Edit Data** → **All Rows**.

Para escrever SQL, use **Tools → Query Tool**. Consultas úteis para a
apresentação:

```sql
-- Pedidos com o nome do cliente
SELECT p.id, c.nome AS cliente, p.status, p.total
FROM pedidos p
JOIN clientes c ON c.id = p.cliente_id
ORDER BY p.id;

-- Itens de um pedido, com o nome do produto e o subtotal
SELECT ip.pedido_id,
       pr.nome AS produto,
       ip.quantidade,
       ip.preco_unitario,
       (ip.quantidade * ip.preco_unitario) AS subtotal
FROM item_pedidos ip
JOIN produtos pr ON pr.id = ip.produto_id
ORDER BY ip.pedido_id;

-- Conferindo que o total gravado bate com a soma dos itens
SELECT p.id,
       p.total AS total_gravado,
       SUM(ip.quantidade * ip.preco_unitario) AS soma_dos_itens
FROM pedidos p
JOIN item_pedidos ip ON ip.pedido_id = p.id
GROUP BY p.id, p.total
ORDER BY p.id;
```

A última é ótima para a banca: mostra na prática que o total não é um número
digitado, e sim o resultado do cálculo.

## 4. Ver o diagrama dos relacionamentos

Botão direito no banco `api_loja_development` → **ERD For Database**.

O pgAdmin desenha as 4 tabelas com as ligações entre elas. **Esse diagrama
serve direto para a apresentação** — dá para exportar como imagem pelo botão
de download na barra do ERD.

## 5. Console do Rails (alternativa ao pgAdmin)

Para consultas rápidas, o console costuma ser mais prático:

```bash
bin/rails console
```

```ruby
Cliente.count
Produto.where("estoque < 10")
Pedido.includes(:cliente, itens: :produto).find(1)
Pedido.find(1).itens.sum(&:subtotal)
```

Sair com `exit`.

## Comandos de banco mais usados

| Comando | O que faz |
|---|---|
| `bin/rails db:create` | cria os bancos |
| `bin/rails db:migrate` | aplica migrations pendentes |
| `bin/rails db:rollback` | desfaz a última migration |
| `bin/rails db:seed` | popula com os dados de exemplo |
| `bin/rails db:reset` | apaga, recria, migra e popula (**apaga tudo**) |
| `bin/rails db:migrate:status` | lista migrations e quais já rodaram |
