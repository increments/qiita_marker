# frozen_string_literal: true

require "test_helper"

class TestCjkFriendlyEmphasis < Minitest::Test
  def test_extension_registered
    assert_includes QiitaMarker.extensions, "cjk_friendly_emphasis"
  end

  def test_basic_cjk_emphasis
    result = QiitaMarker.render_html("これは**太字**です", :DEFAULT, [:cjk_friendly_emphasis])

    assert_equal "<p>これは<strong>太字</strong>です</p>\n", result
  end

  def test_cjk_emphasis_with_punctuation_closing
    result = QiitaMarker.render_html("これは**私のやりたかったこと。**だからするの。", :DEFAULT, [:cjk_friendly_emphasis])

    assert_equal "<p>これは<strong>私のやりたかったこと。</strong>だからするの。</p>\n", result
  end

  def test_cjk_emphasis_with_cjk_punctuation_brackets
    result = QiitaMarker.render_html("太郎は**「こんにちは」**といった", :DEFAULT, [:cjk_friendly_emphasis])

    assert_equal "<p>太郎は<strong>「こんにちは」</strong>といった</p>\n", result
  end

  def test_cjk_emphasis_adjacent_to_ascii
    result = QiitaMarker.render_html("Go**「初心者」**を対象とした記事です。", :DEFAULT, [:cjk_friendly_emphasis])

    assert_equal "<p>Go<strong>「初心者」</strong>を対象とした記事です。</p>\n", result
  end

  def test_cjk_emphasis_multiple
    result = QiitaMarker.render_html("**C#**や**F#**は**「.NET」**というプラットフォーム上で動作します。", :DEFAULT, [:cjk_friendly_emphasis])

    assert_equal "<p><strong>C#</strong>や<strong>F#</strong>は<strong>「.NET」</strong>というプラットフォーム上で動作します。</p>\n", result
  end

  def test_cjk_emphasis_fullwidth_parens
    result = QiitaMarker.render_html(".NET**（.NET Frameworkは不可）**では、", :DEFAULT, [:cjk_friendly_emphasis])

    assert_equal "<p>.NET<strong>（.NET Frameworkは不可）</strong>では、</p>\n", result
  end

  def test_cjk_emphasis_with_links
    result = QiitaMarker.render_html("**[製品ほげ](./product-foo)**と**[製品ふが](./product-bar)**をお試しください", :DEFAULT, [:cjk_friendly_emphasis])

    assert_equal "<p><strong><a href=\"./product-foo\">製品ほげ</a></strong>と<strong><a href=\"./product-bar\">製品ふが</a></strong>をお試しください</p>\n", result
  end

  def test_cjk_emphasis_with_yen_sign
    result = QiitaMarker.render_html("税込**¥10,000**で入手できます。", :DEFAULT, [:cjk_friendly_emphasis])

    assert_equal "<p>税込<strong>¥10,000</strong>で入手できます。</p>\n", result
  end

  def test_cjk_emphasis_with_circled_number
    result = QiitaMarker.render_html("正解は**④**です。", :DEFAULT, [:cjk_friendly_emphasis])

    assert_equal "<p>正解は<strong>④</strong>です。</p>\n", result
  end

  def test_cjk_emphasis_fullwidth_comma
    result = QiitaMarker.render_html("**真，**她", :DEFAULT, [:cjk_friendly_emphasis])

    assert_equal "<p><strong>真，</strong>她</p>\n", result
  end

  def test_cjk_emphasis_cjk_only
    result = QiitaMarker.render_html("**真**她", :DEFAULT, [:cjk_friendly_emphasis])

    assert_equal "<p><strong>真</strong>她</p>\n", result
  end

  def test_cjk_emphasis_supplementary_plane
    result = QiitaMarker.render_html("𰻞𰻞**（ビャンビャン）**麺", :DEFAULT, [:cjk_friendly_emphasis])

    assert_equal "<p>𰻞𰻞<strong>（ビャンビャン）</strong>麺</p>\n", result
  end

  def test_cjk_emphasis_ascii_parens
    result = QiitaMarker.render_html("𰻞𰻞**(ビャンビャン)**麺", :DEFAULT, [:cjk_friendly_emphasis])

    assert_equal "<p>𰻞𰻞<strong>(ビャンビャン)</strong>麺</p>\n", result
  end

  def test_cjk_emphasis_variation_selector
    # U+FE00 variation selector after 塚
    result = QiitaMarker.render_html("大塚︀**(U+585A U+FE00)** 大塚**(U+FA10)**", :DEFAULT, [:cjk_friendly_emphasis])

    assert_equal "<p>大塚︀<strong>(U+585A U+FE00)</strong> 大塚<strong>(U+FA10)</strong></p>\n", result
  end

  def test_cjk_emphasis_fullwidth_quotation_variants
    result = QiitaMarker.render_html("**“\uFE01Git”\uFE01**Hub", :DEFAULT, [:cjk_friendly_emphasis])

    assert_equal "<p><strong>“\uFE01Git”\uFE01</strong>Hub</p>\n", result

    markers = { "*" => "em", "**" => "strong", "~" => "del", "~~" => "del" }
    ["‘", "’", "“", "”"].each do |quote|
      markers.each do |marker, tag|
        input = "#{marker}text#{quote}\uFE01#{marker}Latin"
        result = QiitaMarker.render_html(input, :DEFAULT, [:strikethrough, :cjk_friendly_emphasis])

        assert_equal "<p><#{tag}>text#{quote}\uFE01</#{tag}>Latin</p>\n", result, input
      end
    end
  end

  def test_cjk_quotation_other_variants_remain_non_cjk
    selectors = ["\uFE00", "\uFE02", "\uFE0E"]
    markers = ["**", "~~"]
    ["‘", "’", "“", "”"].each do |quote|
      selectors.each do |selector|
        markers.each do |marker|
          input = "#{marker}text#{quote}#{selector}#{marker}Latin"
          result = QiitaMarker.render_html(input, :DEFAULT, [:strikethrough, :cjk_friendly_emphasis])

          assert_equal "<p>#{input}</p>\n", result, input
        end
      end
    end
  end

  def test_cjk_extension_preserves_gfm_symbol_classification
    # GFM 0.29-gfm treats non-ASCII symbols as text, unlike CommonMark 0.31.2.
    # If the parser's base CommonMark version is updated, its symbol classification
    # may change; update this test's expected output to match the new specification.
    extensions = [[], [:cjk_friendly_emphasis]]
    ["¥", "∇", "😀"].each do |symbol|
      extensions.each do |enabled|
        result = QiitaMarker.render_html("a**#{symbol}x**a", :DEFAULT, enabled)

        assert_equal "<p>a<strong>#{symbol}x</strong>a</p>\n", result
      end
    end
  end

  def test_emphasis_adjacent_to_whitespace
    extension_sets = [[:strikethrough], [:strikethrough, :cjk_friendly_emphasis]]
    texts = ["!text!", "。本文。", "𰻞"]
    spaces = [" ", "\t", "\n", "\u00A0", "\u3000"]
    { "*" => "em", "**" => "strong", "_" => "em", "__" => "strong", "~" => "del", "~~" => "del" }.each do |marker, tag|
      extension_sets.each do |extensions|
        texts.each do |text|
          input = "#{marker}#{text}#{marker}"

          assert_equal "<p><#{tag}>#{text}</#{tag}></p>\n", QiitaMarker.render_html(input, :DEFAULT, extensions), input

          spaces.each do |space|
            input = "a#{space}#{marker}#{text}#{marker}#{space}z"
            expected = "<p>a#{space}<#{tag}>#{text}</#{tag}>#{space}z</p>\n"

            assert_equal expected, QiitaMarker.render_html(input, :DEFAULT, extensions), input
          end
        end
      end
    end
  end

  def test_emphasis_cannot_open_or_close_toward_whitespace
    extension_sets = [[:strikethrough], [:strikethrough, :cjk_friendly_emphasis]]
    spaces = [" ", "\t", "\n", "\u00A0", "\u3000"]
    ["*", "**", "_", "__", "~", "~~"].each do |marker|
      extension_sets.each do |extensions|
        spaces.each do |space|
          ["a#{marker}#{space}text#{marker}z", "a#{marker}text#{space}#{marker}z", "a #{marker}#{space}z"].each do |input|
            assert_equal "<p>#{input}</p>\n", QiitaMarker.render_html(input, :DEFAULT, extensions), input
          end
        end
      end
    end
  end

  def test_cjk_underscore_depends_only_on_adjacent_punctuation
    neighbors = { "a" => false, "中" => false, "𰻞" => false, "😀" => false, "!" => true, "。" => true, "）" => true, "”" => true }
    { "_" => "em", "__" => "strong" }.each do |marker, tag|
      neighbors.each do |before, punct_before|
        neighbors.each do |after, punct_after|
          input = "#{before}#{marker}text#{marker}#{after}"
          expected = if punct_before && punct_after
            "<p>#{before}<#{tag}>text</#{tag}>#{after}</p>\n"
          else
            "<p>#{input}</p>\n"
          end

          assert_equal expected, QiitaMarker.render_html(input, :DEFAULT, [:cjk_friendly_emphasis]), input
        end
      end
    end
  end

  def test_cjk_underscore_uses_punctuation_before_general_use_variation_selector
    bases = ["!", "。", "”", "𰻞", "a"]
    punctuation = ["!", "。", "”"]
    { "_" => "em", "__" => "strong" }.each do |marker, tag|
      bases.each do |base|
        (0xFE00..0xFE0F).each do |selector|
          input = "#{base}#{selector.chr(Encoding::UTF_8)}#{marker}text#{marker}!"
          expected = if selector <= 0xFE0E && punctuation.include?(base)
            "<p>#{base}#{selector.chr(Encoding::UTF_8)}<#{tag}>text</#{tag}>!</p>\n"
          else
            "<p>#{input}</p>\n"
          end

          assert_equal expected, QiitaMarker.render_html(input, :DEFAULT, [:cjk_friendly_emphasis]), input
        end
      end
    end
  end

  def test_asterisks_and_strikethrough_use_cjk_flanking_without_whitespace
    { "*" => "em", "**" => "strong", "~" => "del", "~~" => "del" }.each do |marker, tag|
      input = "中#{marker}(text)#{marker}中"

      assert_equal "<p>中<#{tag}>(text)</#{tag}>中</p>\n", QiitaMarker.render_html(input, :DEFAULT, [:strikethrough, :cjk_friendly_emphasis]), input
    end
  end

  # Strikethrough tests with CJK-friendly emphasis
  def test_single_and_double_tilde_allow_intraword_strikethrough
    extension_sets = [[:strikethrough], [:strikethrough, :cjk_friendly_emphasis]]
    ["~", "~~"].each do |marker|
      extension_sets.each do |extensions|
        input = "a#{marker}text#{marker}z a_text_z"

        assert_equal "<p>a<del>text</del>z a_text_z</p>\n", QiitaMarker.render_html(input, :DEFAULT, extensions), input
      end
    end
  end

  def test_cjk_strikethrough_double_tilde_option_disables_single_tildes
    input = "中~(text)~中 中~~(text)~~中"
    result = QiitaMarker.render_html(input, :STRIKETHROUGH_DOUBLE_TILDE, [:strikethrough, :cjk_friendly_emphasis])

    assert_equal "<p>中~(text)~中 中<del>(text)</del>中</p>\n", result
  end

  def test_strikethrough_cjk_basic
    result = QiitaMarker.render_html("これは~~取消~~です", :DEFAULT, [:strikethrough, :cjk_friendly_emphasis])

    assert_equal "<p>これは<del>取消</del>です</p>\n", result
  end

  def test_strikethrough_cjk_with_punctuation
    result = QiitaMarker.render_html("これは~~私のやりたかったこと。~~だからするの。", :DEFAULT, [:strikethrough, :cjk_friendly_emphasis])

    assert_equal "<p>これは<del>私のやりたかったこと。</del>だからするの。</p>\n", result
  end

  def test_strikethrough_cjk_with_brackets
    result = QiitaMarker.render_html("太郎は~~「こんにちは」~~といった", :DEFAULT, [:strikethrough, :cjk_friendly_emphasis])

    assert_equal "<p>太郎は<del>「こんにちは」</del>といった</p>\n", result
  end

  def test_strikethrough_cjk_multiple
    result = QiitaMarker.render_html("~~C#~~や~~F#~~は~~「.NET」~~というプラットフォーム上で動作します。", :DEFAULT, [:strikethrough, :cjk_friendly_emphasis])

    assert_equal "<p><del>C#</del>や<del>F#</del>は<del>「.NET」</del>というプラットフォーム上で動作します。</p>\n", result
  end

  # Ensure standard behavior is preserved without the extension
  def test_without_extension_cjk_punctuation_not_emphasized
    result = QiitaMarker.render_html("これは**私のやりたかったこと。**だからするの。", :DEFAULT, [])

    assert_equal "<p>これは**私のやりたかったこと。**だからするの。</p>\n", result
  end

  def test_without_extension_standard_emphasis_works
    result = QiitaMarker.render_html("this is **bold** text", :DEFAULT, [])

    assert_equal "<p>this is <strong>bold</strong> text</p>\n", result
  end
end
