module Trixie
  class Template
    def self.render(template_name, to:)
      new(template_name).render(to: to)
    end

    def initialize(template_name)
      @template_name = template_name
    end

    def render(to:)
      path = Pathname.new(to)
      path.write(template_content)
    end

    private

    def template_content
      @template_content = template_path.join(@template_name).read
    end

    def template_path
      Trixie.root_path.join("lib/trixie/templates")
    end
  end
end
