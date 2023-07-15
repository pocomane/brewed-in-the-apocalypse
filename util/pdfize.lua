#!/usr/bin/lua

package.path = package.path .. ';util/?.lua'

local common_css = [[
        .PageBreak {
          page-break-after: always;
        }
        @font-face {
          font-family: "thefont";
          src: url(../thefont.ttf) format("truetype");
        }
        ul {
          //list-style-type: none;
          padding-left: 0pt;
        }
        ul li {
           list-style-position: inside;
        }
        h2 {
          text-align: center;
          text-transform: uppercase;
          font-size: 10pt;
        }
        h3 {
          text-transform: uppercase;
          font-size: 10pt;
        }
        h2:first-letter {
          font-size: 14pt;
        }
        h3:first-letter {
          font-size: 14pt;
        }
        h1:first-letter {
          font-size: 18pt;
        }
        h2:first-letter {
          font-size: 16pt;
        }
        h3:first-letter {
          font-size: 14pt;
        }
        .example {
          font-size: 10pt;
          border: 1pt solid;
          padding: 6pt 6pt 6pt 6pt;
          margin: 0pt 0pt 6pt 0pt;
          text-indent:6pt;
        }
        .example p {
          margin-bottom: 2pt;
          margin-top: 2pt;
        }
]]

local standard_css = [[
        @page {
          size: A4;
          margin-left: 75pt;
          margin-right: 75pt;
          margin-bottom: 75pt;
          margin-top: 60pt;
        }
        body {
          font-family: thefont;
          column-count: 2;
          column-fill: auto;
          font-size: 10pt;
          line-height: 14pt;
          text-align: justify;
        }
        h1 {
          text-align: center;
          text-transform: uppercase;
          font-size: 16pt;
        }
        h1:first-letter {
          font-size: 18pt;
        }
        strong {
          font-weight: normal;
          text-transform: uppercase;
          font-size: 10pt;
          margin-left: 5pt;
          margin-right: 5pt;
        }
]]

local standard_html = [[
  <!doctype html>
  <html>
  <head>
      <title>Example</title>
      <meta charset="utf-8" />
      <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <style type="text/css">
]] .. common_css .. standard_css .. [[
      </style>    
  </head>
  <body>
  <div>
]]


local compact_css = [[
        @page {
          size: A4 landscape;
          margin-left: 60pt;
          margin-right: 60pt;
          margin-bottom: 60pt;
          margin-top: 60pt;
        }
        body {
          font-family: thefont;
          column-count: 3;
          column-fill: auto;
          font-size: 10pt;
          line-height: 14pt;
          text-align: justify;
        }
        h1 {
          text-align: center;
          text-transform: uppercase;
          font-size: 10pt;
          background-color: #000000;
          color: #ffffff;
          border: 4pt solid #000000;
          border-bottom: 2pt solid #000000;
        }
        h1:first-letter {
          font-size: 12pt;
        }
        p {
          margin-top: 4pt;
          margin-bottom: 4pt;
        }
        ul {
          margin-top: 4pt;
          margin-bottom: 4pt;
        }
        li::marker {
            content: '▶ ';
        }
        strong {
          font-weight: normal;
          text-transform: uppercase;
          font-size: 10pt;
          background-color: #000000;
          color: #ffffff;
          border: 3pt solid #000000;
          border-bottom: 1pt solid #000000;
        }
]]

local compact_html = [[
  <!doctype html>
  <html>
  <head>
      <title>Example</title>
      <meta charset="utf-8" />
      <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <style type="text/css">
]] .. common_css .. compact_css .. [[
      </style>    
  </head>
  <body>
  <div>
]]

local end_html = [[
  </div>
  </body>
  </html>
]]

local function render(x, pre, pos)

  local t, e = io.open('build/tmp.md', 'w')
  if e then error(e) end
  t:write(x,'\n')
  t:close()
  local t, err = io.popen('markdown -f footnotes -f fencedcode build/tmp.md')
  if e then error(e) end
  x = t:read('a')
  t:close()
  return  pre .. x .. pos

end

local function make_single_pdf(src, dst, mode)
  if '' ~= dst then
    dst = dst:gsub('%..*$','')
    print('generating '..dst..'.pdf')

    local f, e = io.open(src, 'r')
    if e then error(e) end
    local content = f:read('a')
    f:close()

    content = content:gsub('([\n\r]+)```html,page,break[\n\r]+```', '%1<div class="PageBreak"></div>')

    local x
    if not  mode or 'default' == mode then
      x = render(content, standard_html, end_html)
    elseif mode == 'compact' then
      x = render(content, compact_html, end_html)
    else
      error('unknown output mode "' .. mode .. '"')
    end

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

local function make_pdf()
  os.execute('mkdir -p build')

  local fileliststr = [[
bita.md
bita-strong.md
]]

  local count = 0
  for src in fileliststr:gmatch('[^\n]*') do
    count = count + 1

    local dst = src:match('[^/\\]*$')
    make_single_pdf(src, dst, count == 1 and 'default' or 'compact')
  end
end

-----------------------------------------------------------------------------------

make_pdf()

