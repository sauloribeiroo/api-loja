require "test_helper"

class ClientesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cliente = clientes(:one)
  end

  test "should get index" do
    get clientes_url, as: :json
    assert_response :success
  end

  test "should create cliente" do
    # Email precisa ser diferente do da fixture, senao a validacao de unicidade
    # devolve 422 em vez de criar o registro.
    assert_difference("Cliente.count") do
      post clientes_url, params: { cliente: { email: "carla.dias@exemplo.com", nome: "Carla Dias", telefone: "11966665555" } }, as: :json
    end

    assert_response :created
  end

  test "should not create cliente with invalid data" do
    assert_no_difference("Cliente.count") do
      post clientes_url, params: { cliente: { email: "sem-arroba", nome: "Jo" } }, as: :json
    end

    assert_response :unprocessable_content
  end

  test "should not create cliente with duplicated email" do
    assert_no_difference("Cliente.count") do
      post clientes_url, params: { cliente: { email: @cliente.email, nome: "Outra Pessoa" } }, as: :json
    end

    assert_response :unprocessable_content
  end

  test "should show cliente" do
    get cliente_url(@cliente), as: :json
    assert_response :success
  end

  test "should update cliente" do
    patch cliente_url(@cliente), params: { cliente: { email: @cliente.email, nome: @cliente.nome, telefone: @cliente.telefone } }, as: :json
    assert_response :success
  end

  test "should destroy cliente" do
    assert_difference("Cliente.count", -1) do
      delete cliente_url(@cliente), as: :json
    end

    assert_response :no_content
  end
end
