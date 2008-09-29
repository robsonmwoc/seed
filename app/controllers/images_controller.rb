class ImagesController < ApplicationController
  
  layout nil
  before_filter :login_required
  before_filter :pages_menu, :except => [:create, :new, :destroy]
  
  # TODO solve the problem that results in a No action responded to show error 
  # when calling this (related to the the iframe in the view I think)
  def new
    @image = Image.new
  end
  
  def create
    @image = Image.new(params[:image])
    if @image.save
      responds_to_parent do
        render :update do |page|
            page << "Lightview.hide();"
            page.insert_html :top, 'image-list', :partial => "images/image_item", :object => @image
            page << "if ($('image-size-partial')==null) {"
                page.insert_html :top, 'image-size-options', :partial => "articles/image_size_options"
            page << "}"
            page.insert_html :top, 'image-ids', hidden_field_tag("article[image_ids][]", @image.id, :id => "hidden_image_tag_#{@image.id}")
            page.insert_html :top, 'ajax-msg', "<div id='flash-notice'>Image was successfully uploaded</div>"
        end
      end          
    else
      responds_to_parent do
        render :update do |page|
            page["spinner"].hide
            page.insert_html :top, 'ajax-error', @image.errors.collect{|k,v| "<li>The #{k} #{v}</li>"}.to_s
        end
      end          
    end
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy
    respond_to do |format|
      format.html { redirect_to new_image_path }
      format.js {
        render :update do |page|
          page.remove "image_#{@image.id}"
          page.remove "hidden_image_tag_#{@image.id}"
        end
      }
    end
  end
  
end
