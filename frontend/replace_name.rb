require 'find'
require 'fileutils'

dir = '/Users/jesusbarraza/GitHub/stock-flow/frontend/deteccion_placas'
Find.find(dir) do |path|
  if FileTest.directory?(path)
    if %w(.git build .dart_tool).include?(File.basename(path))
      Find.prune
    else
      next
    end
  else
    begin
      content = File.read(path)
      new_content = content
        .gsub('deteccion_placas', 'stock_flow')
        .gsub('DeteccionPlacas', 'StockFlow')
        .gsub('Deteccion Placas', 'Stock Flow')
        .gsub('deteccion-placas', 'stock-flow')
      
      if content != new_content
        File.write(path, new_content)
        puts "Updated #{path}"
      end
    rescue => e
      # Ignore binary files or unreadable
    end
  end
end
