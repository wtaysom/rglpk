require File.expand_path('helper', File.dirname(__FILE__))

class TestMemoryLeaks < Minitest::Test
  include Examples
    
  def test_memory_prof
    5.times do
      1000.times do |i|
        brief_example
      end
      
      change = change_to_real_memory_in_kb
      assert (change < 10000), "memory leak #{change}kb"
    end
  end
  
  def real_memory_in_kb
    # "=" after "rss" strips the header line.
    `ps -p #{Process.pid} -o rss=`.to_i
  end
  
  def change_to_real_memory_in_kb
    GC.start
    r = real_memory_in_kb
    @change_to_real_memory_in_kb__prev ||= r
    r - @change_to_real_memory_in_kb__prev
  ensure
    @change_to_real_memory_in_kb__prev = r
  end
end
