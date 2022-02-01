# DO NOT EDIT! THIS FILE IS AUTOGENERATED BY lib/GD/Image_pm.PL
package GD::Image;

use strict;
use GD;
use Symbol 'gensym','qualify_to_ref';
use vars '$VERSION';
$VERSION = '2.75';

=head1 NAME

GD::Image - Image class for the GD image library

=head1 SYNOPSIS

See L<GD>

=head1 DESCRIPTION

Supported Image formats:

=over 4

=item Png

=item Gif

=item Jpeg

=item Tiff

=item Xpm

=item WBMP

=item GifAnim

=item Webp

=item Heif

=item Avif

=back

Unsupported Image formats:

=over 4

=item Gd

=item Gd2

=back

See L<GD>

=head1 AUTHOR

The GD.pm interface is copyright 1995-2005, Lincoln D. Stein.  It is
distributed under the same terms as Perl itself.  See the "Artistic
License" in the Perl source code distribution for licensing terms.

The latest versions of GD.pm are available on CPAN:

  http://www.cpan.org

=head1 SEE ALSO

L<GD>
L<GD::Polyline>,
L<GD::SVG>,
L<GD::Simple>,
L<Image::Magick>

=cut

# Copyright 1995 Lincoln D. Stein.  See accompanying README file for
# usage information

*stringTTF = \&GD::Image::stringFT;

sub _make_filehandle {
  shift;  # get rid of class
  no strict 'refs';
  my $thing = shift;
  return $thing if defined(fileno $thing);

  # otherwise try qualifying it into caller's package
  my $fh;
  {   
    local $^W = 0;  # to avoid uninitialized variable warning from Symbol.pm
    $fh = qualify_to_ref($thing,caller(2));
  }
  return $fh if defined(fileno $fh);

  # otherwise treat it as a file to open
  $fh = gensym;
  if (!open($fh,$thing)) {
    die "$thing not found: $!";
    return undef;
  }
  return $fh;
}

sub new {
  my $pack = shift;
  if (@_ == 1) {
    if (my $type = _image_type($_[0])) {
      my $method = "newFrom${type}Data";
      return unless $pack->can($method);
      return $pack->$method($_[0]);
    }
    return unless my $fh = $pack->_make_filehandle($_[0]);
    my $magic;
    return unless read($fh,$magic,4);
    return unless my $type = _image_type($magic);
    seek($fh,0,0);
    my $method = "newFrom${type}";
    return $pack->$method($fh);
  }
  return $pack->_new(@_);
}

sub newTrueColor {
  my $pack = shift;
  return $pack->_new(@_, 1);
}

sub newPalette {
  my $pack = shift;
  return $pack->_new(@_, 0);
}

sub ellipse ($$$$$) {
  my ($self,$cx,$cy,$width,$height,$color) = @_;
  $self->arc($cx,$cy,$width,$height,0,360,$color);
}

# draws closed polygon with the specified color
sub polygon {
    my $self = shift;
    my($p,$c) = @_;
    $self->openPolygon($p, $c);
    $self->line( @{$p->{'points'}->[0]},
	    @{$p->{'points'}->[$p->{'length'}-1]}, $c);
}

sub width {
  my $self = shift;
  my @bounds = $self->getBounds;
  $bounds[0];
}

sub height {
  my $self = shift;
  my @bounds = $self->getBounds;
  $bounds[1];
}

sub _image_type {
  my $data = shift;
  my $magic = substr($data,0,4);
  return 'Png'  if $magic eq "\x89PNG";
  return 'Jpeg' if ((substr($data,0,3) eq "\377\330\377") &&
    ord(substr($data,3,1)) >= 0xc0);
  return 'Gif'  if $magic eq "GIF8";
  return 'Gd2'  if $magic eq "gd2\000";
  return 'Tiff' if $magic eq "\x4d\x4d\x00\x2a" or
    $magic eq "\x49\x49\x2a\x00" or
    $magic eq "IIN1";
  return 'Webp' if substr($data,0,12) eq "RIFF2\0\0\0WEBP";
  return 'Heif' if $magic eq '\000\000\000\030'
                and substr($data,4,4) eq "ftyp"
                and (substr($data,8,4) eq "heic"
                  or substr($data,8,4) eq "heix");
  return 'Avif' if $magic eq '\000\000\000\030'
                and substr($data,4,4) eq "ftyp"
                and (substr($data,8,4) eq "avif"
                  or substr($data,8,4) eq "mif1");
  return 'Xpm'  if substr($data,0,9) eq "/* XPM */" or $magic eq '/* X';
  return 'Xbm'  if substr($data,0,8) eq "#define " or $magic eq "#def";
  return;
}


sub clone {
  croak("Usage: clone(\$image)") unless @_ == 1;
  my $self = shift;
  my ($x,$y) = $self->getBounds;
  my $new = $self->new($x,$y);
  return unless $new;
  $new->copy($self,0,0,0,0,$x,$y);
  return $new;
}

sub newFromPng {
    croak("Usage: newFromPng(class,filehandle,[truecolor])") unless @_>=2;
    my($class) = shift;
    my($f)     = shift;
    my $fh = $class->_make_filehandle($f);
    binmode($fh);
    $class->_newFromPng($fh,@_);
}

sub newFromJpeg {
    croak("Usage: newFromJpeg(class,filehandle,[truecolor])") unless @_>=2;
    my($class) = shift;
    my($f)     = shift;
    my $fh = $class->_make_filehandle($f);
    binmode($fh);
    $class->_newFromJpeg($fh,@_);
}

sub newFromGif {
    croak("Usage: newFromGif(class,filehandle)") unless @_==2;
    my($class) = shift;
    my($f)     = shift;
    my $fh = $class->_make_filehandle($f);
    binmode($fh);
    $class->_newFromGif($fh,@_);
}

sub newFromTiff {
    croak("Usage: newFromTiff(class,filehandle)") unless @_==2;
    my($class,$f) = @_;
    my $fh = $class->_make_filehandle($f);
    binmode($fh);
    $class->_newFromTiff($fh);
}

sub newFromXbm {
    croak("Usage: newFromXbm(class,filehandle)") unless @_==2;
    my($class,$f) = @_;
    my $fh = $class->_make_filehandle($f);
    binmode($fh);
    $class->_newFromXbm($fh);
}

sub newFromWebp {
    croak("Usage: newFromWebp(class,filehandle)") unless @_==2;
    my($class,$f) = @_;
    my $fh = $class->_make_filehandle($f);
    binmode($fh);
    $class->_newFromWebp($fh);
}

sub newFromHeif {
    croak("Usage: newFromHeif(class,filehandle)") unless @_==2;
    my($class,$f) = @_;
    my $fh = $class->_make_filehandle($f);
    binmode($fh);
    $class->_newFromHeif($fh);
}

sub newFromAvif {
    croak("Usage: newFromAvif(class,filehandle)") unless @_==2;
    my($class,$f) = @_;
    my $fh = $class->_make_filehandle($f);
    binmode($fh);
    $class->_newFromAvif($fh);
}

sub newFromWBMP {
    croak("Usage: newFromWBMP(class,filehandle)") unless @_==2;
    my($class) = shift;
    my($f)     = shift;
    my $fh = $class->_make_filehandle($f);
    binmode($fh);
    $class->_newFromWBMP($fh,@_);
}

# Autoload methods go after __END__, and are processed by the autosplit program.
1;
__END__
