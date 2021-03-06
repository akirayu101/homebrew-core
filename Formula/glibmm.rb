class Glibmm < Formula
  desc "C++ interface to glib"
  homepage "https://www.gtkmm.org/"
  url "https://download.gnome.org/sources/glibmm/2.56/glibmm-2.56.0.tar.xz"
  sha256 "6e74fcba0d245451c58fc8a196e9d103789bc510e1eee1a9b1e816c5209e79a9"

  bottle do
    cellar :any
    sha256 "611cb45e6240e9fc41a1e38fdcfdaa303e4b5b8a98ef7c40f497d59490c2c3bc" => :high_sierra
    sha256 "46991472465a244c04cbbef29e15d5194bc9af3a66b1cae0b277779882cdd075" => :sierra
    sha256 "25b785a0b869d958dc61f782413c5af4e65d742c8aaf3afe30240b764651d235" => :el_capitan
    sha256 "d9e829f5a3be7d9fd93d3d01ea675bbbdd747d2d4bd59d9f102ad93e9edbfcb7" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "libsigc++"
  depends_on "glib"

  needs :cxx11

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j6" if ENV["CIRCLECI"]

    ENV.cxx11

    # see https://bugzilla.gnome.org/show_bug.cgi?id=781947
    # Note that desktopappinfo.h is not installed on Linux
    # if these changes are made.
    inreplace "gio/giomm/Makefile.in" do |s|
      s.gsub! "OS_COCOA_TRUE", "OS_COCOA_TEMP"
      s.gsub! "OS_COCOA_FALSE", "OS_COCOA_TRUE"
      s.gsub! "OS_COCOA_TEMP", "OS_COCOA_FALSE"
    end if OS.mac?

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <glibmm.h>

      int main(int argc, char *argv[])
      {
         Glib::ustring my_string("testing");
         return 0;
      }
    EOS
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    libsigcxx = Formula["libsigc++"]
    flags = %W[
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/glibmm-2.4
      -I#{libsigcxx.opt_include}/sigc++-2.0
      -I#{libsigcxx.opt_lib}/sigc++-2.0/include
      -I#{lib}/glibmm-2.4/include
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{libsigcxx.opt_lib}
      -L#{lib}
      -lglib-2.0
      -lglibmm-2.4
      -lgobject-2.0
      -lsigc-2.0
    ]
    flags << "-lintl" if OS.mac?
    system ENV.cxx, "-std=c++11", "test.cpp", "-o", "test", *flags
    system "./test"
  end
end
