class String
  def to_i_or_s
    if to_i.to_s == self
      to_i
    else
      self
    end
  end
end

# stolen from http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/53779
module VersionSorter
  extend self

  def sort(list)
    list.sort { |a, b| versioncmp(a, b) }
  end


  def array_sort_hash(list)
    hash = list.inject({}) do |acc, v|
      acc[v.scan(/(\d+|[[:alpha:]]+)/).flatten.collect { |p| p.to_i_or_s }] = v
      acc
    end
    hash.keys.sort.collect { |k| hash[k] }
  end
  
  def array_sort_array(list)
    list = list.inject([]) do |acc, v|
      acc << [v.scan(/(\d+|[[:alpha:]]+)/).flatten.collect { |p| p.to_i_or_s }, v]
    end
    list.sort.collect { |k| k[-1] }
  end

  def rsort(list)
    list.sort { |a, b| -versioncmp(a, b) }
  end

private
  def versioncmp(version_a, version_b)
    vre = /[-.]|\d+|[^-.\d]+/
    ax = version_a.scan(vre)
    bx = version_b.scan(vre)

    while ax.length > 0 && bx.length > 0
      a = ax.shift
      b = bx.shift

      if( a == b )                 then next
      elsif (a == '-' && b == '-') then next
      elsif (a == '-')             then return -1
      elsif (b == '-')             then return 1
      elsif (a == '.' && b == '.') then next
      elsif (a == '.' )            then return -1
      elsif (b == '.' )            then return 1
      elsif (a =~ /^\d+$/ && b =~ /^\d+$/) then
        if( a =~ /^0/ or b =~ /^0/ ) then
          return a.to_s.upcase <=> b.to_s.upcase
        end
        return a.to_i <=> b.to_i
      else
        return a.upcase <=> b.upcase
      end
    end

    version_a <=> version_b
  end
end

puts

if $0 == __FILE__
  require 'test/unit'

  class VersionSorterTest < Test::Unit::TestCase
    include VersionSorter

    def test_sorts_verisons_correctly
      versions = %w(1.0.9 1.0.10 2.0 3.1.4.2 1.0.9a)
      sorted_versions = %w( 1.0.9 1.0.9a 1.0.10 2.0 3.1.4.2 )

      assert_equal sorted_versions, sort(versions)
    end

    def test_array_sort_hash_sorts_verisons_correctly
      versions = %w(1.0.9 1.0.10 2.0 3.1.4.2 1.0.9a)
      sorted_versions = %w( 1.0.9 1.0.9a 1.0.10 2.0 3.1.4.2 )

      assert_equal sorted_versions, array_sort_hash(versions)
    end

    def test_array_sort_array_sorts_verisons_correctly
      versions = %w(1.0.9 1.0.10 2.0 3.1.4.2 1.0.9a)
      sorted_versions = %w( 1.0.9 1.0.9a 1.0.10 2.0 3.1.4.2 )

      assert_equal sorted_versions, array_sort_array(versions)
    end

    def test_reverse_sorts_verisons_correctly
      versions = %w(1.0.9 1.0.10 2.0 3.1.4.2 1.0.9a)
      sorted_versions = %w( 3.1.4.2 2.0 1.0.10 1.0.9a 1.0.9 )

      assert_equal sorted_versions, rsort(versions)
    end
  end

  require 'benchmark'
  versions = IO.read('tags_without_X.X.X.txt').split("\n")
  count = 10
  Benchmark.bm(20) do |x|
    x.report("sort")             { count.times { VersionSorter.sort(versions) } }
    x.report("array_sort_hash")  { count.times { VersionSorter.array_sort_hash(versions) } }
    x.report("array_sort_array") { count.times { VersionSorter.array_sort_array(versions) } }
  end
  puts

end
