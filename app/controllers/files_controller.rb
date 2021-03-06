class FilesController < ApplicationController
  respond_to :html, :json

  def index
    if params['fingerprint']
      files = FileDocument.where(:fingerprint=>params['fingerprint'])
      if files.any?
        render :nothing=>true, :status =>:found and return
      else
        render :nothing=>true, :status =>:not_found and return
      end
    end
    #thumbnails 260x180 looks good
    @selected_tags = params['tags'].blank? ? [] : params['tags']
    @files = FileDocument.find_by_tags(@selected_tags)
    respond_with @files
  end

  def show
    @file = FileDocument.find(params['id'])
    respond_with @file
  end

  def destroy
    FileDocument.find(params['id']).destroy
    respond_to do |format|
      format.html { redirect_to files_path(:tags=>selected_tags) }
      format.json { render :nothing=>true, :status=>200  }
    end
  end
  
  def create
    document = params['document']
    if params['tags']
      if params['tags'].include?('[')
        tags = JSON.parse(params['tags'])
      elsif params['tags'].include?(',')
        tags =  params['tags'].split(',')
      else
        tags = params['tags']
      end
    end
    @file = FileDocument.create(:tags=>tags)
    @file.set_data document
    @file.save
    #Don't redirect on JS send Created with info instead!
    respond_to do |format|
      format.html { redirect_to files_path(:tags=>selected_tags) }
      format.json { render :json=>@file, :location=>file_url(@file), :status=>201 }
    end
  end

  def update
    @file = FileDocument.find(params['id'])
    @file.update_attributes(params)
    respond_with @file
  end

  def get_data
    document = FileDocument.find(params['id'])
    send_data document.file.data, type: document.file.content_type, disposition: 'inline'
  end

  private

  def selected_tags
    [].concat(params['tags'].to_a).compact.reject(&:blank?)
  end
end
