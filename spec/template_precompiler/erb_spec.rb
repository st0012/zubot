require "spec_helper"

describe Zubot::TemplatePrecompiler do
  before :context do
    subject = Zubot::TemplatePrecompiler.new
    subject.view_paths = view_paths
    subject.compile_templates!
  end

  before do
    allow_any_instance_of(Zubot::TemplatePrecompiler).to receive(:view) { view }
    # Shouldn't be compile while rendering
    expect_any_instance_of(ActionView::Template).not_to receive(:compile)
  end

  describe "#compile_template" do
    let(:resolver) { view_paths.first }

    it "compiles erb template" do
      view.render(template: "index", prefixes: "posts")
    end
    it "compiles erb template with namespaces (users)" do
      view.render(template: "index", prefixes: "posts/users")
    end
    it "compiles partial" do
      view.render(template: "show", prefixes: "posts")
    end
    it "doesn't mess partial's locals" do
      result1 = view.render("posts/title", title: "Hello1" )
      result2 = view.render("posts/title", title: "Hello2" )
      expect(result1).not_to eq(result2)
    end
    it "renders nested partial" do
      result = view.render(template: "posts/double_partial")
      expect(result).to eq("Partial1:\n<br>\n\nPartial2: Hello World\n\n\n")
    end
    it "compiles templates with script" do
      result = view.render(template: "posts/with_scripts/show")
      expect(result).to eq("Hello\n<script type='text/javascript'></script>\n\n")
    end
    it "compiles templates with layout" do
      result = view.render(template: "posts/index", layout: "layouts/application")
      expect(result).to eq("<header>\n</header>\n  <p>Hello World!</p>\n\n<footer>\n</footer>\n")
    end
    it "compiles templates with layout and content_for" do
      result = view.render(template: "posts/content_for/show", layout: "layouts/content_for/application")
      expect(result).to eq("<head>\n    <meta name=\"theme-color\" content=\"#1A1918\">\n\n</head>\n\n\nThis is post.\n\n<footer>This is footer</footer>\n")
    end

    context "when user checks local in partials" do
      it "returns \"Test\" instead of \"hello world\" in pattern 1" do
        result = view.render(template: "posts/local_check/pattern1")

        expect(result).to eq("<h1>Test</h1>\n\n")
      end
      it "returns \"Test\" instead of \"hello world\" in pattern 2" do
        result = view.render(template: "posts/local_check/pattern2")

        expect(result).to eq("<h1>Test</h1>\n\n")
      end
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
        handlers: [:raw, :erb, :html, :builder, :ruby]
      )
      expect(args[4]).to be_a(ActionView::LookupContext::DetailsKey)
      expect(args[5]).to eq([])
    end
  end
end
