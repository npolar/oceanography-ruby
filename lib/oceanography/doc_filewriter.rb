module Oceanography
  class DocFileWriter

    attr_reader :log

    def initialize(config)
      @log = config[:log]
    end

    def write(docs, original_file)
      path = get_file_path(original_file)
      docs.each {|doc| write_to_file(doc, path)}
      log.info("Wrote #{docs.size} docs to #{path}")
    end

    private
    def write_to_file(doc, path)
      file = File.join(path, doc["id"]+".json")
      log.debug("Writing #{file}")
      unless File.directory?(path)
        FileUtils.mkdir_p(path)
      end
      File.open(File.join(path, doc["id"]+".json"), "w") {|f| f.write(JSON.pretty_generate(doc)) }
    end

    def get_file_path(file)
      File.join(config.out_path, file[/(.+#{File::SEPARATOR}).+.nc$/ui, 1])
    end
  end
end
