require File.dirname(__FILE__) + '/../test_helper'
require 'pictures_controller'

# Re-raise errors caught by the controller.
class PicturesController; def rescue_action(e) raise e end; end

class PicturesControllerTest < Test::Unit::TestCase
  fixtures :pictures

  def setup
    @controller = PicturesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = 1

    @request.cookies[AppConstant.config["authentication_cookie_name"]] = CGI::Cookie.new(AppConstant.config["authentication_cookie_name"], OPNET_AUTHENTICATION_COOKIE)
    @request.env["HTTP_AUTHORIZATION"] = OPNET_AUTHENTICATION_SOAP
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:items)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:picture)
    assert assigns(:picture).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:picture)
  end

  def test_create
    num_pictures = Picture.count

    post :create, :picture => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_pictures + 1, Picture.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:picture)
    assert assigns(:picture).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Picture.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Picture.find(@first_id)
    }
  end
end
