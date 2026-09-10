class ClientesController < ApplicationController
  before_action :set_cliente, only: %i[ show update destroy ]

  # GET /clientes
  def index
    @clientes = Cliente.all

    render json: @clientes
  end

  # GET /clientes/1
  def show
    render json: @cliente
  end

  # POST /clientes
  def create
    @cliente = Cliente.new(cliente_params)

    if @cliente.save
      render json: @cliente, status: :created, location: @cliente
    else
      render json: { errors: @cliente.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PATCH/PUT /clientes/1
  def update
    if @cliente.update(cliente_params)
      render json: @cliente
    else
      render json: { errors: @cliente.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /clientes/1
  # Um cliente com pedidos nao pode ser apagado (restrict_with_error no model),
  # entao respondemos 422 em vez de deixar a excecao virar 500.
  def destroy
    if @cliente.destroy
      head :no_content
    else
      render json: { errors: @cliente.errors.full_messages }, status: :unprocessable_content
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cliente
      @cliente = Cliente.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def cliente_params
      params.expect(cliente: [ :nome, :email, :telefone ])
    end
end
