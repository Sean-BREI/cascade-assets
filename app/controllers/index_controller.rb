class IndexController < ApplicationController
  def index
    @one_column_pages   = html_files_in '1_column'
    @two_column_pages   = html_files_in '2_column'
    @three_column_pages = html_files_in '3_column'
    @home_page_pages    = html_files_in 'home_page'
  end

  def one_column
    render template: "1_column/#{params[:page]}", layout: '1_column'
  end

  def two_column
    render template: "2_column/#{params[:page]}", layout: '2_column'
  end

  def three_column
    render template: "3_column/#{params[:page]}", layout: '3_column'
  end

  def home_page
    render template: "home_page/#{params[:page]}", layout: 'home_page'
  end

  private
    def html_files_in(folder)
      extention = '.html.erb'
      Dir[Rails.root.join('app', 'views', folder, '*' + extention)].map do |path|
        File.basename(path, extention)
      end
    end
end