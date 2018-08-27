require 'anemone'
require 'nokogiri'
require 'kconv'

def scraping_amazon_ranking
  urls = ['https://www.amazon.co.jp/gp/bestsellers/books/466282']
  ranking_list = []

  Anemone.crawl(urls, :depth_limit => 0, :skip_query_strings => true) do |anemone|
    anemone.on_every_page do |page|
      doc = Nokogiri::HTML.parse(page.body.toutf8)

      category = doc.xpath(
        "//*[@id='zg_listTitle']/span").text

      items = doc.xpath(
        "//*[@class='zg_itemRow']/div[1]/div[1]")

      items.each do |item|
        title = item.xpath("div[2]/a/div").text
        base_url = 'https://www.amazon.co.jp'
        url = base_url +
                    item.xpath("div[2]/a").attribute('href').to_s.match(/(.+)\/ref/)[1]
        image = item.xpath("div[1]/a/img").attribute('src')

        title_url_image = [title, url, image]
        ranking_list.push(title_url_image)
      end
    end
  end

  return ranking_list
end