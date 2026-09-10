require "test_helper"

class PedidosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pedido = pedidos(:pago)
    @cliente = clientes(:one)
    @teclado = produtos(:teclado)
    @mouse = produtos(:mouse)
    @esgotado = produtos(:esgotado)
  end

  test "should get index" do
    get pedidos_url, as: :json
    assert_response :success
  end

  test "should get pedidos of a cliente" do
    get cliente_pedidos_url(@cliente), as: :json
    assert_response :success

    corpo = response.parsed_body
    assert corpo.all? { |pedido| pedido["cliente"]["id"] == @cliente.id },
           "a rota aninhada deve devolver apenas pedidos do cliente informado"
  end

  test "should show pedido with cliente and itens" do
    get pedido_url(@pedido), as: :json
    assert_response :success

    corpo = response.parsed_body
    assert_equal @pedido.id, corpo["id"]
    assert corpo["cliente"].present?, "o pedido deve trazer o cliente embutido"
    assert corpo["itens"].present?, "o pedido deve trazer os itens embutidos"
  end

  test "should create pedido calculando o total e baixando o estoque" do
    estoque_anterior = @teclado.estoque

    assert_difference([ "Pedido.count", "ItemPedido.count" ], 1) do
      post pedidos_url,
           params: { pedido: { cliente_id: @cliente.id,
                               itens: [ { produto_id: @teclado.id, quantidade: 2 } ] } },
           as: :json
    end

    assert_response :created

    corpo = response.parsed_body
    # 2 unidades a 289.90 = 579.80, calculado pela API e nao enviado por quem chamou
    assert_equal "579.8", corpo["total"].to_f.to_s
    assert_equal estoque_anterior - 2, @teclado.reload.estoque
  end

  test "should not create pedido sem itens" do
    assert_no_difference("Pedido.count") do
      post pedidos_url, params: { pedido: { cliente_id: @cliente.id, itens: [] } }, as: :json
    end

    assert_response :unprocessable_content
  end

  test "should not create pedido sem estoque suficiente" do
    assert_no_difference([ "Pedido.count", "ItemPedido.count" ]) do
      post pedidos_url,
           params: { pedido: { cliente_id: @cliente.id,
                               itens: [ { produto_id: @esgotado.id, quantidade: 1 } ] } },
           as: :json
    end

    assert_response :unprocessable_content
  end

  test "should not create pedido com produto repetido" do
    assert_no_difference("Pedido.count") do
      post pedidos_url,
           params: { pedido: { cliente_id: @cliente.id,
                               itens: [ { produto_id: @mouse.id, quantidade: 1 },
                                        { produto_id: @mouse.id, quantidade: 2 } ] } },
           as: :json
    end

    assert_response :unprocessable_content
  end

  test "nao deve alterar estoque quando um item do pedido falha" do
    estoque_anterior = @teclado.estoque

    post pedidos_url,
         params: { pedido: { cliente_id: @cliente.id,
                             itens: [ { produto_id: @teclado.id, quantidade: 1 },
                                      { produto_id: @esgotado.id, quantidade: 1 } ] } },
         as: :json

    assert_response :unprocessable_content
    assert_equal estoque_anterior, @teclado.reload.estoque,
                 "a transacao deve desfazer a baixa de estoque do item valido"
  end

  test "should update status do pedido" do
    patch pedido_url(@pedido), params: { pedido: { status: "enviado" } }, as: :json
    assert_response :success
    assert_equal "enviado", @pedido.reload.status
  end

  test "should not update com status invalido" do
    patch pedido_url(@pedido), params: { pedido: { status: "voando" } }, as: :json
    assert_response :unprocessable_content
  end

  test "should destroy pedido" do
    assert_difference("Pedido.count", -1) do
      delete pedido_url(@pedido), as: :json
    end

    assert_response :no_content
  end

  test "apagar pedido devolve o estoque dos produtos" do
    # O pedido :pago tem 1 teclado e 2 mouses.
    estoque_teclado = @teclado.estoque
    estoque_mouse = @mouse.estoque

    delete pedido_url(@pedido), as: :json
    assert_response :no_content

    assert_equal estoque_teclado + 1, @teclado.reload.estoque
    assert_equal estoque_mouse + 2, @mouse.reload.estoque
  end
end
