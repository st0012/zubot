require "spec_helper"

describe Zubot::TemplatePrecompiler do
  before do
    allow(subject).to receive(:view_paths) { view_paths }
  end

  describe "#compile_templates!" do
    before do
      allow(subject).to receive(:view_paths) { view_paths }
    end

    it "compiles one template" do
      subject.compile_templates!

      expect(subject.compiled_count).to eq(3)
    end
  end

  describe "#compile_template" do
    let(:resolver) { view_paths.first }
    before do
      allow(subject).to receive(:view) { ActionView::Base.new(view_paths, {}, nil, [:html]) }
    end
    it "compiles erb template" do
      file_path = implicit_file_path("posts/index.html.erb")
      subject.compile_template(file_path, resolver)

      # Shouldn't be compile while rendering
      expect_any_instance_of(ActionView::Template).not_to receive(:compile)
      view.render(template: "index", prefixes: "posts")
    end
    it "compiles partial" do
      template_path = implicit_file_path("posts/show.html.erb")
      partial_path = implicit_file_path("posts/_title.html.erb")
      subject.compile_template(template_path, resolver)
      subject.compile_template(partial_path, resolver)

      # Shouldn't be compile while rendering
      expect_any_instance_of(ActionView::Template).not_to receive(:compile)
      view.render(template: "show", prefixes: "posts")
    end
  end

  describe "#template_args" do
    let(:template_path) { posts_index_template_path }

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
end
