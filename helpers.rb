# 配列に格納されている本リストから、ランダムに1件取得し、その本のタイトル、個別URL、画像URLをreturnする
def return_title_url_image(ranking_list)
  random_number = rand(0..19)
  book_title = ranking_list[random_number][0]
  book_title.gsub!(' ', '')
  book_url = URI.decode(ranking_list[random_number][1]) + '/?openExternalBrowser=1'
  book_url.gsub!('、', URI.encode('、'))
  book_image = ranking_list[random_number][2]

  return book_title, book_url, book_image
end