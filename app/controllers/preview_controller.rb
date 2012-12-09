class PreviewController < ApplicationController
  
  
  def load
    url = params[:url]
    client = HTTPClient.new
    begin
      url_response = client.get(url,:follow_redirect => true)
    rescue Exception
      render :json => {:error => "Unable to load website. Make sure your url is properly formatted (e.g http://www.nordstrom.com)"}
      return
    end
    doc = Nokogiri::HTML(url_response.body)
    response = {}
    response[:images] = []
    doc.xpath("//img").each do |img|
      response[:images].push(URI.join(url,img['src']).to_s)
    end
    render :json => response
  end
  
end
