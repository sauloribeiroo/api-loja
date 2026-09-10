# Endpoint de boas-vindas na raiz da API.
# Sem ele, acessar "/" devolve 404 - correto, mas confuso para quem abre a URL
# no navegador sem saber quais recursos existem.
class RaizController < ApplicationController
  def show
    render json: {
      api: "API Loja",
      versao: "1.0",
      descricao: "API REST de clientes, produtos e pedidos",
      endpoints: {
        clientes: {
          listar: "GET /clientes",
          buscar: "GET /clientes/:id",
          criar: "POST /clientes",
          atualizar: "PATCH /clientes/:id",
          remover: "DELETE /clientes/:id",
          pedidos_do_cliente: "GET /clientes/:id/pedidos"
        },
        produtos: {
          listar: "GET /produtos",
          buscar: "GET /produtos/:id",
          criar: "POST /produtos",
          atualizar: "PATCH /produtos/:id",
          remover: "DELETE /produtos/:id"
        },
        pedidos: {
          listar: "GET /pedidos",
          buscar: "GET /pedidos/:id",
          criar: "POST /pedidos",
          mudar_status: "PATCH /pedidos/:id",
          remover: "DELETE /pedidos/:id"
        },
        health_check: "GET /up"
      },
      exemplo_criar_pedido: {
        metodo: "POST /pedidos",
        corpo: {
          pedido: {
            cliente_id: 1,
            itens: [
              { produto_id: 1, quantidade: 2 },
              { produto_id: 2, quantidade: 1 }
            ]
          }
        },
        observacao: "Nenhum preco e enviado: a API busca o preco atual de cada " \
                    "produto, calcula o total e baixa o estoque."
      },
      totais: {
        clientes: Cliente.count,
        produtos: Produto.count,
        pedidos: Pedido.count
      }
    }
  end
end
