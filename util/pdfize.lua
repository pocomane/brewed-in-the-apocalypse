#!/usr/bin/lua

package.path = package.path .. ';util/?.lua'

local function render(x)

  local t, e = io.open('build/tmp.md', 'w')
  if e then error(e) end
  t:write(x,'\n')
  t:close()
  local t, err = io.popen('markdown -f footnotes -f fencedcode build/tmp.md')
  if e then error(e) end
  x = t:read('a')
  t:close()

  x = [[
  <!doctype html>
  <html>
  <head>
      <title>Example</title>
      <meta charset="utf-8" />
      <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <style type="text/css">
        @page {
          size: A4;
          margin-left: 75pt;
          margin-right: 75pt;
          margin-bottom: 75pt;
          margin-top: 60pt;
        }
        body {
          column-count: 2;
          font: 12pt "Sans";
          line-height: 14pt;
          //text-align: justify;
        }
        /*
        .PageBreak {
          page-break-after: always;
        }
        */
        ul {
          //list-style-type: none;
          padding-left: 0pt;
        }
        strong {
          font-weight: normal;
          text-transform: uppercase;
          font: 10pt "Sans";
          margin-left: 5pt;
          margin-right: 5pt;
        }
        h1 {
          text-align: center;
          text-transform: uppercase;
          font: 16pt "Sans";
        }
        h2 {
          text-align: center;
          text-transform: uppercase;
          font: 12pt "Sans";
        }
        h3 {
          text-transform: uppercase;
          font: 12pt "Sans";
        }
        h1:first-letter {
          font: 18pt "Sans";
        }
        h2:first-letter {
          font: 14pt "Sans";
        }
        h3:first-letter {
          font: 14pt "Sans";
        }
        h1:first-letter {
          font: 18pt "Sans";
        }
        h2:first-letter {
          font: 16pt "Sans";
        }
        h3:first-letter {
          font: 14pt "Sans";
        }
        .example {
          font: 12pt "Sans";
          background-color: #DDDDDD;
          padding: 6pt 6pt 6pt 26pt;
          text-indent:-20px;
        }
        .example p {
          margin-bottom: 2pt;
          margin-top: 2pt;
        }
      </style>    
  </head>
  <body>
  <div>
  ]] .. x .. [[
  </div>
  </body>
  </html>
  ]]

  return x
end

local function make_pdf()
  os.execute('mkdir -p build')

  local fileliststr = [[
bita.md
]]

  for src in fileliststr:gmatch('[^\n]*') do

    local dst = src:match('[^/\\]*$')
    if '' ~= dst then
      dst = dst:gsub('%..*$','')
      print('generating '..dst..'.pdf')

      local f, e = io.open(src, 'r')
      if e then error(e) end
      local content = f:read('a')
      f:close()

      local x=render(content)

      x = x:gsub('<pre><code>(.-)</code></pre>',function(content)
        return '<div class="example"><p>'..(content:gsub('(\n\r?\n)','</p>%1<p>'))..'</p></div>'
      end)

      local f, e = io.open('build/'..dst..'.html', 'wb')
      if e then error(e) end

      f:write(x)
      f:close()

      local ok, st, err = os.execute('weasyprint build/'..dst..'.html build/'..dst..'.pdf')
      if 'exit' ~= st then error(err) end
    end
  end
end

-----------------------------------------------------------------------------------

make_pdf()

