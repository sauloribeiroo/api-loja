require "test_helper"

class ProdutosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @produto = produtos(:teclado)
    # esgotado nao participa de nenhum pedido, entao pode ser apagado
    @sem_pedidos = produtos(:esgotado)
  end

  test "should get index" do
    get produtos_url, as: :json
    assert_response :success
  end

  test "should create produto" do
    assert_difference("Produto.count") do
      post produtos_url,
           params: { produto: { nome: "Mousepad XL", descricao: "Mousepad 90x40cm",
                                preco: 79.90, estoque: 30 } },
           as: :json
    end

    assert_response :created
  end

  test "should not create produto com preco negativo" do
    assert_no_difference("Produto.count") do
      post produtos_url, params: { produto: { nome: "Invalido", preco: -1, estoque: -5 } }, as: :json
    end

    assert_response :unprocessable_content
  end

  test "should show produto" do
    get produto_url(@produto), as: :json
    assert_response :success
  end

  test "should update produto" do
    patch produto_url(@produto), params: { produto: { preco: 319.90 } }, as: :json
    assert_response :success
    assert_equal 319.90, @produto.reload.preco
  end

  test "should destroy produto sem pedidos" do
    assert_difference("Produto.count", -1) do
      delete produto_url(@sem_pedidos), as: :json
    end

    assert_response :no_content
  end

  test "should not destroy produto que esta em um pedido" do
    assert_no_difference("Produto.count") do
      delete produto_url(@produto), as: :json
    end

    assert_response :unprocessable_content
  end
end
