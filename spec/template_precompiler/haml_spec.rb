require "spec_helper"
require "action_view/template"

describe Zubot::TemplatePrecompiler do
  before :context do
    require "haml"
    require "haml/template"
    subject = Zubot::TemplatePrecompiler.new
    subject.view_paths = view_paths
    subject.compile_templates!
  end

  subject do
    precompiler = Zubot::TemplatePrecompiler.new
    precompiler.view_paths = view_paths
    precompiler
  end

  before do
    # Shouldn't be compile while rendering
    expect_any_instance_of(ActionView::Template).not_to receive(:compile)
  end

  describe "#compile_template" do
    let(:resolver) { view_paths.first }
    before do
      allow(subject).to receive(:view) { ActionView::Base.new(view_paths, {}, nil, [:html]) }
    end
    it "compiles haml template" do
      view.render(template: "index", prefixes: "posts")
    end
    it "compiles partial" do
      view.render(template: "show", prefixes: "posts")
    end
  end

  describe "#template_args" do
    let(:template_path) { posts_index_template_path }

    before do
      allow(subject).to receive(:view_paths) { view_paths }
    end

    it "returns right values" do
      resolver = view_paths.first
      resolver_path = resolver.instance_variable_get(:@path)
      args = subject.send(:template_args, template_path, resolver_path)
      expect(args[0]).to eq("index")
      expect(args[1]).to eq("posts")
      expect(args[2]).to be_falsey
      expect(args[3]).to eq(
        locale: [:en],
        formats: [:html],
        variants: [],
        handlers: [:raw, :erb, :html, :builder, :ruby, :haml]
      )
      expect(args[4]).to be_a(ActionView::LookupContext::DetailsKey)
      expect(args[5]).to eq([])
    end
  end
end

ActionView::Template.unregister_template_handler(:haml)

