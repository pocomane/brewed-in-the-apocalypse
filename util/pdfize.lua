#!/usr/bin/lua

package.path = package.path .. ';util/?.lua'

local common_css = [[
        .PageBreak {
          page-break-after: always;
        }
        @font-face {
          font-family: "thefont";
          src: url(../util/thefont.ttf) format("truetype");
        }
        ul {
          //list-style-type: none;
          padding-left: 0pt;
        }
        ul li {
           list-style-position: inside;
        }
]]

local standard_css = [[
        @page {
          size: A5;
          margin-left: 70pt;
          margin-right: 70pt;
          margin-bottom: 50pt;
          margin-top: 50pt;
        }
        @page :left {
          margin-left: 70pt;
          margin-right: 50pt;
        }
        @page :right {
          margin-left: 50pt;
          margin-right: 70pt;
        }
        body {
          font-family: thefont;
          column-count: 1;
          column-fill: balanced;
          font-size: 8pt;
          line-height: 10pt;
          text-align: justify;
        }
        strong {
          font-weight: normal;
          text-transform: uppercase;
          font-size: 8pt;
          margin-left: 3pt;
          margin-right: 3pt;
        }
        h1 {
          text-align: center;
          text-transform: uppercase;
          font-size: 10pt;
        }
        h1:first-letter {
          font-size: 12pt;
        }
        h2 {
          text-transform: uppercase;
          font-size: 10pt;
        }
        h2:first-letter {
          font-size: 12pt;
        }
        h3 {
          text-transform: uppercase;
          font-size: 10pt;
        }
        h3:first-letter {
          font-size: 11pt;
        }
        .example {
          font-size: 8pt;
          border: 1pt solid;
          padding: 4pt 4pt 4pt 4pt;
          margin: 0pt 0pt 6pt 0pt;
          text-indent:8pt;
        }
        .example p {
          margin-bottom: 2pt;
          margin-top: 2pt;
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
          size: A5 landscape;
          margin-left: 30pt;
          margin-right: 30pt;
          margin-bottom: 30pt;
          margin-top: 20pt;
        }
        body {
          font-family: thefont;
          column-count: 2;
          column-fill: balanced;
          font-size: 8pt;
          line-height: 10pt;
          text-align: justify;
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
          font-size: 8pt;
          background-color: #000000;
          color: #ffffff;
          border: 1pt solid #000000;
          border-left: 2pt solid #000000;
          border-right: 2pt solid #000000;
        }
        h1 {
          text-align: center;
          text-transform: uppercase;
          font-size: 8pt;
          background-color: #000000;
          color: #ffffff;
          border: 4pt solid #000000;
          border-bottom: 2pt solid #000000;
        }
        h2 {
          text-align: center;
          text-transform: uppercase;
          font-size: 8pt;
        }
        h3 {
          text-transform: uppercase;
          font-size: 8pt;
        }
        .example {
          font-size: 10pt;
          border: 1pt solid;
          padding: 4pt 4pt 4pt 4pt;
          margin: 0pt 0pt 6pt 0pt;
          text-indent:6pt;
        }
        .example p {
          margin-bottom: 2pt;
          margin-top: 2pt;
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

    local date = os.date('!%Y-%m-%d %H:%M:%SZ')
    content = content:gsub('TODO.-\n\r?\n', '')
    content = content:gsub('[^\n]*revision[^\n]*', '%0 '..date..'. This is a DRAFT. Look at the markdown version for a TODO list.', 1)
    
    content = content:gsub('([\n\r]+)```html,page,break[\n\r]+```', '%1<div class="PageBreak"></div>')
    content = content:gsub('([\n\r]+)```html,move,diagram[\n\r]+```', '%1<img src="../move_diagram.svg" style="column-span:all;width:200%%;"></img>')

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

    --os.execute('cd build && pdfjam --landscape --signature 1 '..dst..'.pdf')
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

