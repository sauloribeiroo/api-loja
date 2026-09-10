require "test_helper"

class RaizControllerTest < ActionDispatch::IntegrationTest
  test "a raiz da api responde com a lista de endpoints" do
    get root_url, as: :json
    assert_response :success

    corpo = response.parsed_body
    assert_equal "API Loja", corpo["api"]
    assert corpo["endpoints"]["clientes"].present?
    assert corpo["endpoints"]["produtos"].present?
    assert corpo["endpoints"]["pedidos"].present?
  end
end
