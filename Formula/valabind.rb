class Valabind < Formula
  desc "Vala bindings for radare, reverse engineering framework"
  homepage "https://radare.org/"
  url "https://github.com/radare/valabind/archive/1.4.0.tar.gz"
  sha256 "b2e4939912feada6138b8269d228ea82fb0f1391fd2e2e7003f404677b0cdbc9"
  head "https://github.com/radare/valabind.git"

  bottle do
    sha256 "09ecd58afe5c101c661d20c18a229ca4d8204adfd65d508e6e46387faf8a5980" => :high_sierra
    sha256 "05e13594c23aca12a1ea9c7ff4a5e3a17bbe1a68a65dea80d5a8aa89892d26cf" => :sierra
    sha256 "bf466be7a14313608f3d68a86135b2b25094457c0fb89b7dd389f57fc4cd173c" => :el_capitan
    sha256 "893e3cfe19a35979ceabb87df4e31a8e1107ca3a2b124ade6d8c4a3c75d034d3" => :x86_64_linux
  end

  depends_on "pkg-config" # not :build, for vala
  depends_on "swig"

  # vala dependencies
  depends_on "gettext"
  depends_on "glib"
  unless OS.mac?
    depends_on "bison" => :build
    depends_on "flex" => :build
  end

  # Upstream issue "Build failure with vala 0.38.0"
  # Reported 6 Sep 2017 https://github.com/radare/valabind/issues/43
  resource "vala" do
    url "https://download.gnome.org/sources/vala/0.36/vala-0.36.5.tar.xz"
    sha256 "7ae7eb8a976005afecf4f647b9043f2bb11e8b263c7fe9e905ab740b3d8a9f40"
  end

  def install
    resource("vala").stage do
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{libexec}"
      system "make"
      system "make", "install"
    end

    ENV.prepend_path "PATH", libexec/"bin"
    ENV.prepend_path "PKG_CONFIG_PATH", libexec/"lib/pkgconfig"
    # Ensure that libvala will be found.
    ENV.append "LDFLAGS", "-Wl,-rpath,#{libexec}/lib" unless OS.mac?

    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system bin/"valabind", "--help"
  end
end
