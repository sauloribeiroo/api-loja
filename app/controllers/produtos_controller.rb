class ProdutosController < ApplicationController
  before_action :set_produto, only: %i[ show update destroy ]

  # GET /produtos
  def index
    @produtos = Produto.all

    render json: @produtos
  end

  # GET /produtos/1
  def show
    render json: @produto
  end

  # POST /produtos
  def create
    @produto = Produto.new(produto_params)

    if @produto.save
      render json: @produto, status: :created, location: @produto
    else
      render json: @produto.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /produtos/1
  def update
    if @produto.update(produto_params)
      render json: @produto
    else
      render json: @produto.errors, status: :unprocessable_content
    end
  end

  # DELETE /produtos/1
  # destroy (sem !) devolve false quando o restrict_with_error bloqueia,
  # permitindo responder 422 em vez de estourar uma excecao.
  def destroy
    if @produto.destroy
      head :no_content
    else
      render json: { errors: @produto.errors.full_messages }, status: :unprocessable_content
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_produto
      @produto = Produto.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def produto_params
      params.expect(produto: [ :nome, :descricao, :preco, :estoque ])
    end
end
