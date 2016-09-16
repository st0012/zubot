module TemplateHelper
  def view
    @view ||= begin
      ActionView::Base.new(view_paths, {}, nil, [:html])
    end
  end

  def view_paths
    @view_paths ||= begin
      path = ActionView::OptimizedFileSystemResolver.new(fixture_load_path)
      ActionView::PathSet.new([path])
    end
  end

  def fixture_load_path
    File.join(File.dirname(__FILE__), "../", "fixtures", "templates")
  end

  def implicit_file_path(filename_with_prefix)
    File.join(fixture_load_path, filename_with_prefix)
  end

  def posts_index_template_path
     Dir.glob("#{fixture_load_path}/posts/index.*").first
  end
end
