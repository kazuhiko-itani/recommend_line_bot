require 'anemone'
require 'nokogiri'
require 'kconv'

def scraping_amazon_ranking
  urls = ['https://www.amazon.co.jp/gp/bestsellers/books/466282']

  Anemone.crawl(urls, :depth_limit => 0, :skip_query_strings => true) do |anemone|
    anemone.on_every_page do |page|
      doc = Nokogiri::HTML.parse(page.body.toutf8)

      category = doc.xpath(
        "//*[@id='zg_listTitle']/span").text

      items = doc.xpath(
        "//*[@class='zg_itemRow']/div[1]/div[1]")

      ranking_list = []
      items.each do |item|
       title = item.xpath("div[2]/a/div").text
       url = item.xpath("div[2]/a").attribute('href').to_s.match(/(.+)\/ref/)[1]
       pair = [title, url]
       ranking_list.push(pair)
      end
    end
  end

  return ranking_list
end

