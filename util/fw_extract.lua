#!/bin/lua5.3

local f = io.open("build/fw_extract.html", "r")
if not f then

  print('retriving from the web...')
  local http = require 'socket.http'
  local page = http.request("http://fantasyworldrpg.com/eng/4-The-World.html")

  os.execute('mkdir -p build/')
  local o = io.open("build/fw_extract.html", "w")
  if nil == o then error('can not open temp file') end
  o:write(page)
  o:close()

  f = io.open("build/fw_extract.html", "r")
  if nil == f then error('can not open temp file') end
end
page = f:read('a')
f:close()
print('parsing...')

page = page:gsub('^.-<p>', '<h1 id="04-the-world">The World</h1>\n\n<p>')
page = page:gsub('</section>.*', '')
page = page:gsub('<hr>[\n\r \t]*$', '')

page = page:gsub('[ \t]*<hr>[\n\r \t]*<h([0-9]) [^>]*>([^<]*)</h[0-9]*>', function(a,b) return '\n'..('#'):rep(a=='1'and 1 or (tonumber(a)-1)).." "..b:gsub('^[ \t]*[0-9.]*[ \t]*%-[ \t]*','')..'\n' end)
page = page:gsub('[ \t]*<h([0-9]) [^>]*>([^<]*)</h[0-9]*>', function(a,b) return '\n'..('#'):rep(a=='1'and 1 or (tonumber(a)-1)).." "..b:gsub('^[ \t]*[0-9.]*[ \t]*%-[ \t]*','')..'\n' end)
page = page:gsub('<br>', "\n\n")
page = page:gsub('<p>(.-)</p>', "%1\n\n")
page = page:gsub('<em>(.-)</em>', "_%1_")
page = page:gsub('<strong>(.-)</strong>', "__%1__")
page = page:gsub('[ \t]*<blockquote>(.-)</blockquote>', "\n\n```\n%1\n```\n\n")

local function recls(a, count, level)
  level = level or 0
  a = a:gsub('@ul(%b{})', function(a) return recls(a:sub(2,#a-1), '-', level + 1) end)
  a = a:gsub('@ol(%b{})', function(a) return recls(a:sub(2,#a-1), 0, level + 1) end)
  if '-' == count then
    a = a:gsub('<li>(.-)</li>', function(a)
      a = a:gsub('^[ \t\r\n]*', '')
      a = a:gsub('[ \t\r\n]*$', '')
      a = a:gsub('^_?_([^_]*)_?_$', '%1')
      return ("  "):rep(level).."- "..a
    end)
  end
  if 'number' == type(count) then
    a = a:gsub('<li>(.-)</li>', function(a)
      count = count + 1
      a = a:gsub('^[ \t\r\n]*', '')
      a = a:gsub('[ \t\r\n]*$', '')
      a = a:gsub('^_?_([^_]*)_?_$', '%1')
      return ("  "):rep(level)..tostring(count)..". "..a
    end)
  end
  return a
end
page = page:gsub('<([uo]l)>','@%1{')
page = page:gsub('</([uo]l)>','}')
page = recls(page)

page = page:gsub('[ \t]*<table>(.-)</table>[ \t]*', function(t)
  local table = {}
  for r in t:gmatch('<tr>(.-)</tr>') do
    table[1+#table] = {}
    for c in r:gmatch('<td>(.-)</td>') do
      local row = table[#table]
      row[1+#row] = c:gsub('\r?\n',' '):gsub('^[ \t\r\n]*',''):gsub('[ \t\r\n]*$','')
    end
  end
  local result = '\n\n  <table>'
  for _, r in pairs(table) do
    result = result .. '<tr>'
    for _, c in pairs(r) do
      result = result .. '<td>\n\n'
      result = result .. c
      result = result .. '\n\n  </td>'
    end
    result = result .. '</tr>'
  end
  result = result .. '</table>\n\n'
  return result
end)

page = page:gsub('(\r?\n)[\n\r]+', "%1%1")

page = page:gsub('&amp;', "&")
page = page:gsub('&apos;', "'")
page = page:gsub('&quot;', '"')
page = page:gsub('&#x2019;', "'")
page = page:gsub('&#x201[Cc];', '"')
page = page:gsub('&#x201[Dd];', '"')
page = page:gsub('&#x([0-9A-Fa-f][0-9A-Fa-f]);', function(a) return string.char(tonumber(a,16))  end)
page = page:gsub('&#x([0-9A-Fa-f][0-9A-Fa-f])([0-9A-Fa-f][0-9A-Fa-f]);', function(a,b) return string.char(tonumber(a,16))..string.char(tonumber(b,16))  end)

local f = io.open("util/fw_extract.md", "w")
if nil == f then error('can not open out file') end
f:write("\nLicensed under CC BY 4.0 by Alessandro Piroddi, Luca Maiorani, MS Edizioni, 2020-2023. Got from https://fantasyworldrpg.com\n")
f:write(page)
f:close()

os.execute[[vim -n -c "set nocindent" -c "normal ggvGgq" -c wq "util/fw_extract.md"]]

print('done')

