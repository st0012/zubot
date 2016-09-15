require "spec_helper"

describe Zubot::TemplatePrecompiler do
  describe "#compile_templates!" do
    before do
      allow(subject).to receive(:view_paths) { view_paths }
    end

    it "compiles one template" do
      subject.compile_templates!

      expect(subject.compiled_count).to eq(1)
    end
  end

  describe "#template_args" do
    let(:template_path) { Dir.glob("#{fixture_load_path}/**/*.*").first }

    before do
      allow(subject).to receive(:view_paths) { view_paths }
    end

    it "returns right values" do
      args = subject.send(:template_args, template_path)
      expect(args[0]).to eq("index")
      expect(args[1]).to eq("posts")
      expect(args[2]).to be_falsey
      expect(args[3]).to eq(
        locale: [:en],
        formats: [:html],
        variants: [],
        handlers: [:raw, :erb, :html, :builder, :ruby]
      )
      expect(args[4]).to be_a(ActionView::LookupContext::DetailsKey)
      expect(args[5]).to eq([])
    end
  end

  def view
    @view ||= begin
      ActionView::Base.new(view_paths)
    end
  end

  def view_paths
    @view_paths ||= begin
      path = ActionView::OptimizedFileSystemResolver.new(fixture_load_path)
      ActionView::PathSet.new([path])
    end
  end

  def fixture_load_path
    File.join(File.dirname(__FILE__), "fixtures", "templates")
  end
end
