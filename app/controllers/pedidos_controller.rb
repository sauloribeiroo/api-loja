class PedidosController < ApplicationController
  before_action :set_pedido, only: %i[ show update destroy ]

  # GET /pedidos
  # GET /clientes/:cliente_id/pedidos
  def index
    # includes evita o problema N+1: sem ele, listar 50 pedidos faria
    # 1 consulta para os pedidos + 50 para os clientes + 50 para os itens.
    escopo = Pedido.includes(:cliente, itens: :produto).order(created_at: :desc)
    escopo = escopo.where(cliente_id: params[:cliente_id]) if params[:cliente_id]

    render json: escopo.map { |pedido| pedido_json(pedido) }
  end

  # GET /pedidos/1
  def show
    render json: pedido_json(@pedido)
  end

  # POST /pedidos
  def create
    @pedido = Pedido.new(pedido_params)

    if @pedido.save
      render json: pedido_json(@pedido), status: :created, location: @pedido
    else
      render json: { errors: @pedido.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PATCH/PUT /pedidos/1
  # Só o status é editável: mexer nos itens de um pedido já fechado
  # bagunçaria o estoque que já foi baixado.
  def update
    if @pedido.update(pedido_update_params)
      render json: pedido_json(@pedido)
    else
      render json: { errors: @pedido.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /pedidos/1
  def destroy
    @pedido.destroy!
  end

  private
    def set_pedido
      @pedido = Pedido.includes(:cliente, itens: :produto).find(params.expect(:id))
    end

    # A API recebe "itens", mas o accepts_nested_attributes_for espera
    # "itens_attributes". A troca acontece aqui para o JSON ficar natural.
    def pedido_params
      permitidos = params.expect(
        pedido: [ :cliente_id, :status, itens: [ [ :produto_id, :quantidade ] ] ]
      )
      itens = permitidos.delete(:itens)
      permitidos[:itens_attributes] = itens if itens.present?
      permitidos
    end

    def pedido_update_params
      params.expect(pedido: [ :status ])
    end

    # Monta a resposta com o cliente e os itens embutidos, em vez de
    # devolver apenas as colunas cruas da tabela pedidos.
    def pedido_json(pedido)
      {
        id: pedido.id,
        status: pedido.status,
        total: pedido.total,
        criado_em: pedido.created_at,
        cliente: {
          id: pedido.cliente.id,
          nome: pedido.cliente.nome,
          email: pedido.cliente.email
        },
        itens: pedido.itens.map do |item|
          {
            id: item.id,
            produto_id: item.produto_id,
            produto: item.produto.nome,
            quantidade: item.quantidade,
            preco_unitario: item.preco_unitario,
            subtotal: item.subtotal
          }
        end
      }
    end
end
