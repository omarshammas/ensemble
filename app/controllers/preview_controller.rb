class PreviewController < ApplicationController
  
  
  def load
    url = params[:url]
    client = HTTPClient.new
    url_response = client.get(url,:follow_redirect => true)
    doc = Nokogiri::HTML(url_response.body)
    response = {}
    response[:images] = []
    doc.xpath("//img").each do |img|
      response[:images].push(URI.join(url,img['src']).to_s)
    end
    render :json => response
  end
  
end
