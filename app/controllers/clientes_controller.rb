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
      render json: @cliente.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /clientes/1
  def update
    if @cliente.update(cliente_params)
      render json: @cliente
    else
      render json: @cliente.errors, status: :unprocessable_content
    end
  end

  # DELETE /clientes/1
  def destroy
    @cliente.destroy!
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
