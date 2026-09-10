# Guia: deploy no Render

Passo a passo para publicar a API. O projeto já está preparado — a
configuração de produção, o script de build e a `DATABASE_URL` foram
ajustados nos commits anteriores.

## Antes de começar

- [ ] Código no GitHub, atualizado (`git push`)
- [ ] Conta no Render: https://render.com (dá para entrar com a conta do GitHub)
- [ ] A `RAILS_MASTER_KEY` em mãos — ela está no arquivo `config/master.key`
      do seu projeto. **Abra o arquivo e copie o conteúdo.** Ele não está no
      GitHub de propósito (o `.gitignore` bloqueia), justamente por ser secreto.

---

## Passo 1 — Criar o banco de dados

1. No painel do Render, clique em **New +** → **Postgres**
2. Preencha:

   | Campo | Valor |
   |---|---|
   | Name | `api-loja-db` |
   | Database | `api_loja` |
   | Region | a mais próxima (ex.: Ohio) |
   | Plan | **Free** |

3. **Create Database** e aguarde o status virar **Available**
4. Na página do banco, role até **Connections** e copie a **Internal Database
   URL**. É um texto começando com `postgres://`. Guarde — será usada no
   Passo 2.

> **Anote a região escolhida.** O serviço web precisa ficar na mesma região do
> banco, senão a conexão interna não funciona.

---

## Passo 2 — Criar o serviço web

1. **New +** → **Web Service**
2. Conecte sua conta do GitHub e escolha o repositório `api-loja`
3. Preencha:

   | Campo | Valor |
   |---|---|
   | Name | `api-loja` |
   | Region | **a mesma do banco** |
   | Branch | `master` |
   | Runtime / Language | `Ruby` |
   | Build Command | `./bin/render-build.sh` |
   | Start Command | `bundle exec puma -C config/puma.rb` |
   | Plan | **Free** |

4. Ainda antes de criar, abra **Advanced** → **Add Environment Variable** e
   cadastre:

   | Chave | Valor |
   |---|---|
   | `DATABASE_URL` | a *Internal Database URL* copiada no Passo 1 |
   | `RAILS_MASTER_KEY` | o conteúdo de `config/master.key` |
   | `RAILS_ENV` | `production` |
   | `RODAR_SEEDS` | `1` |

   O `RODAR_SEEDS` faz o primeiro deploy popular o banco com os dados de
   exemplo. **Depois do primeiro deploy dar certo, apague essa variável** —
   senão as seeds rodam de novo a cada push.

5. **Create Web Service**

O Render começa o build. Leva vários minutos na primeira vez, porque ele
compila todas as gems do zero.

---

## Passo 3 — Verificar

Quando o status virar **Live**, sua URL será algo como
`https://api-loja.onrender.com`.

Teste na ordem:

```
GET  https://api-loja.onrender.com/up          → deve responder 200
GET  https://api-loja.onrender.com/produtos    → lista dos 5 produtos das seeds
GET  https://api-loja.onrender.com/clientes    → lista dos 4 clientes
GET  https://api-loja.onrender.com/pedidos     → 3 pedidos com totais calculados
```

A rota `/up` é o *health check* que o Rails já traz pronto: responde 200 se a
aplicação subiu sem erros. É o primeiro lugar para olhar quando algo falha.

---

## Passo 4 — Limpeza

1. Apague a variável `RODAR_SEEDS` (Environment → botão de lixeira → Save)
2. A partir daí, todo `git push` para `master` dispara um deploy automático

---

## Avisos importantes para a apresentação

**O plano gratuito hiberna.** Depois de cerca de 15 minutos sem receber
requisições, o serviço dorme. A requisição seguinte demora **30 a 60 segundos**
para responder enquanto ele acorda — e isso vai acontecer exatamente na hora da
sua apresentação, se a última requisição foi no ensaio.

> **Faça uma requisição alguns minutos antes de apresentar** para acordar o
> serviço. Abrir a URL `/up` no navegador já resolve.

**O banco gratuito tem prazo de validade.** O Render expira instâncias
gratuitas de PostgreSQL depois de um período. Confira a data de expiração na
página do banco assim que criar, e certifique-se de que ela é posterior ao dia
da apresentação. Se estiver perto, crie o banco mais tarde ou tenha o plano B
abaixo.

**Plano B: apresentar rodando local.** Deixe o projeto funcionando na sua
máquina (`bin/rails server`) como alternativa. Se a internet da faculdade
falhar ou o Render tiver problema, você apresenta pelo `localhost:3000` sem
depender de nada externo. Vale testar isso antes.

---

## Se o deploy falhar

Abra a aba **Logs** no Render e procure a **primeira** linha de erro (não a
última — o erro real costuma estar no começo do rastro).

| Sintoma | Causa provável | Solução |
|---|---|---|
| `Permission denied` no build | `bin/render-build.sh` sem permissão de execução | `git update-index --chmod=+x bin/render-build.sh` e faça push |
| `your bundle only supports platform` | falta a plataforma Linux no lock | `bundle lock --add-platform x86_64-linux` e push |
| `PG::ConnectionBad` | `DATABASE_URL` errada, ou banco em outra região | confira a variável e a região |
| `Missing encryption key` | `RAILS_MASTER_KEY` ausente ou incorreta | recopie de `config/master.key` |
| Responde 500 em tudo | migrations não rodaram | veja no log se o `db:migrate` do build passou |

Os dois primeiros já foram corrigidos neste projeto, mas ficam listados porque
são os erros mais comuns de quem desenvolve no Windows e publica no Linux.
