class Acpica < Formula
  desc "OS-independent implementation of the ACPI specification"
  homepage "https://www.acpica.org/"
  url "https://acpica.org/sites/acpica/files/acpica-unix-20180313.tar.gz"
  sha256 "958b5b75617732f6024484c32476cf0759b5777eb827a5e45f1cf3b45d174b15"
  head "https://github.com/acpica/acpica.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "c50f54f64b9891359a2f6ff496553a275990c7c117dc5087e0f2aa78ccf398bf" => :high_sierra
    sha256 "23e8cc3bd0408ba2efe4201bc17bd8f1c8cc757b9f77afa1d3258d83b8c95e01" => :sierra
    sha256 "59d4456d75b19a9e864e1764dcacacdfe43c4cdc6bf2f93d7444a3994d7669bf" => :el_capitan
    sha256 "2723a2015b865557d38a8e0f73f2e29ce35616150ff6146b94a7fc0d65727fcc" => :x86_64_linux
  end

  unless OS.mac?
    depends_on "bison" => :build
    depends_on "flex" => :build
    depends_on "m4" => :build
  end

  def install
    ENV.deparallelize
    system "make", "PREFIX=#{prefix}"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system "#{bin}/acpihelp", "-u"
  end
end
