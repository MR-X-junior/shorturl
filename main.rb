#!/usr/bin/env ruby

=begin

MIT License

Copyright (c) 2022 Rahmat 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

=end

require 'uri'
require 'erb'
require 'json'
require 'lolcat'
require 'launchy'
require 'net/http'
require 'net/https'

class NilClass
  def [](key)
    return {}
  end
end

$logo = <<-KONTOL
 ____  _                _     _   _ ____  _
/\ ___|| |__   ___  _ __| |_  | | | |  _ \\| |
\\___ \\| '_ \\ /\ _ \\| '__| __| | | | | |_) | |
 ___) | | | | (_) | |  | |_  | |_| |  _ <| |___
|____/\|_| |_|\\___/\|_|   \\__|  \\___/\|_| \\_\\_____|

\t  Created By ( Rahmat adha )

 Github: MR-X-Junior | Facebook: rahmat.adha72

KONTOL

def AddData(long, short, file = 'link.txt')
  a = File.read(file)
  a << "#{'-'*40}\nLong  URL : #{long}\nShort URL : #{short}\n#{'-'*40}\n"
  File.write(file,a)
end

def lolcat(str = '', **opts)
  opts = { :animate => false, :duration => 12, :os => rand * 8192, :speed => 20, :spread => 8.0, :freq => 0.3 }.update(opts)
  fd = StringIO.new
  fd << str
  fd.rewind

  Lol.cat(fd,opts)

  fd.close
end

def main()
  system ('clear')
  lolcat($logo)
  lolcat ("[01] Short link\n[02] More Them Us\n[00] Exit\n\n[?] Pilih : ")
  pilih = Integer(STDIN.gets, exception: false)

  case pilih
    when nil
      lolcat("[!] Invalid Input :(\n")
      sleep(0.9)
      main()
    when 0 then abort("\033[1;91m[!] Exit!\033[0m")     
    when 1
      puts ('')
      lolcat("[+] Select Provider [+]\n\n[1] tinyurl\n[2] bit.ly\n[3] cutt.ly\n\n[?] Pilih : ")
      prov = Integer(STDIN.gets, exception: false)
      case prov
        when 1
          puts ('')
          lolcat("[?] Paste A Long URL : ")
          url = STDIN.gets.chomp

          puts ('')
          lolcat("[!] Pleace Wait...\n")

          endpoint = URI('http://tinyurl.com/api-create.php?url=' + url)
          req = Net::HTTP.get_response(endpoint)

          AddData(long = url, short = req.body) if req.code.to_s == '200'

          puts ('')
          lolcat("#{(req.code.to_s == '200') ? '[✓]' : '[!]'} Shortned Url : #{req.body}\n[!] Exit!\n")
          exit
        when 2
          puts ('')
          lolcat("[?] Paste A Long URL : ")
          url = STDIN.gets.chomp

          puts ('')
          lolcat("[!] Place Wait...\n")

          validate = url.match(/^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix)
          title = (validate.nil?) ? "" : Net::HTTP.get(URI(url)).match(/<title.*?>(.*)<\/title>/)[1]

          token = "51f55d39061d4636b1f9a3df04523f25e63527be"
          headers = {"Authorization"=>"Bearer #{token}","Content-Type" => "application/json"}
          data = {'domain'=>'bit.ly','long_url'=>url}
          endpoint = URI("https://api-ssl.bitly.com/v4/shorten")

          http = Net::HTTP.new(endpoint.host, endpoint.port)
          http.use_ssl = true
          req = Net::HTTP::Post.new(endpoint.path, headers)
          req.body = data.to_json
          res = http.request(req)
          data = JSON.parse(res.body)

          AddData(long = url, short = data['link']) if res.code.to_s == '200'

          puts ('')
          lolcat("#{((res.code.to_s == '200') ? '[✓] Message  : OK - the link has been shortened :)' : '[!] Message  : ' + data['message'].to_s)}\n[✓] Title Web: #{title}\n[✓] Create at: #{data['created_at']}\n[✓] FullLink : #{url}\n[✓] ShortLink: #{data['link']}\n[!] Exit!\n")
          exit
        else
          puts ('')
          lolcat('[?] Paste A Long URL : ')
          url = STDIN.gets.chomp

          lolcat("[?] Custom ending (Optional): ")
          ending = STDIN.gets.chomp

          puts ('')
          lolcat("[!] Pleace Wait...\n")

          api_key = "f7b400b435bef26ca4555566cfb1bbde59822"
          endpoint = URI("https://cutt.ly/api/api.php?key=#{api_key}&short=#{url}&name=#{ending}")

          req = Net::HTTP::Post.new(endpoint)
          res = Net::HTTP.start(endpoint.host, endpoint.port, :use_ssl => true) {|http| http.request(req)}
          data = JSON.parse(res.body)

          AddData(long = url, short = data['url']['shortLink']) if res.code.to_s == '200'

          puts ('')

          case data['url']['status']
            when 1 then lolcat("[!] Message  : The shortened link comes from the domain that shortens the link, i.e. the link has already been shortened\n")
            when 2 then lolcat("[!] Message  : The entered link is not a link\n")
            when 3 then lolcat("[!] Message  : The preferred link name is already taken\n")
            when 4 then lolcat("[!] Message  : Invalid API key\n")
            when 5 then lolcat("[!] Message  : The link has not passed the validation. Includes invalid characters\n")
            when 6 then lolcat("[!] Message  : he link provided is from a blocked domain\n")
            when 7 then lolcat("[✓] Message  : OK - the link has been shortened :)\n")
          end
          lolcat("[✓] Title Web: #{data['url']['title']}\n[✓] Create at: #{data['url']['date']}\n[✓] FullLink : #{data['url']['fullLink']}\n[✓] ShortLink: #{data['url']['shortLink']}\n[!] Exit!\n")
          exit
      end
    when 2
      Launchy.open("https://github.com/MR-X-Junior")
      sleep(0.3)
      main()
    else
      lolcat("[!] Invalid Input!\n")
      sleep(0.7)
      main()
  end
end
if __FILE__ == $0
  begin
    File.write('link.txt','') if !File.file? ('link.txt')
    begin File.chmod(0o777,'link.txt');rescue;end
    main()
  rescue Interrupt then abort("\033[1;91m[!] Exit!\033[0m")
  rescue SocketError then abort("\033[1;91m[!] No Connection\033[0m")
  rescue Errno::ETIMEDOUT then abort("\033[1;93m[!] Connection timed out\033[0m")
  rescue Errno::ENETUNREACH,Errno::ECONNRESET then abort("\033[1;93m[!] There is an error\n[!] Pleace Try Again :)\033[0m")
  rescue Errno::ECONNREFUSED then abort("\033[1;91m[!] Pleace Check Your Internet Connection!\033[0m")
  end
end
