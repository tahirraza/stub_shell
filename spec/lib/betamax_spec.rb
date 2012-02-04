require 'spec_helper'

describe StubShell do
  describe "stubbing a command with backquote" do
    it "should set the correct value for STDOUT" do
      shell_context do
        command "ls /tmp/foobar" do
          stdout "hey there"
        end
      end
      
      `ls /tmp/foobar`.should == 'hey there'
    end
    
    it "should have an exitstatus of 0 by default" do      
      shell_context do
        command "ls /tmp/foobar" do
          stdout "hey there"
        end
      end
      
      `ls /tmp/foobar`
      $?.exitstatus.should == 0
    end
    
    it "should allow the user to set a non-zero exit status" do
      shell_context do
        command "ls /tmp/foobar" do
          stdout "hey there"
          exitstatus 1
        end
      end
      
      `ls /tmp/foobar`
      $?.exitstatus.should == 1
    end
  end  
  
  describe "using a shell context after the shell state has been mutated" do
    it "should use the return value from the nested context" do
      shell_context do
        command 'ls /tmp/foobar' do
          stdout 'yes, foobar exists'
        end

        command "rm /tmp/foobar" do
          stderr 1

          shell_context do
            command 'ls /tmp/foobar' do
              stdout 'the file no longer exists'
            end
          end
        end
      end

      `ls /tmp/foobar`.should == 'yes, foobar exists'
      `rm /tmp/foobar`
      `ls /tmp/foobar`.should == 'the file no longer exists'
    end
    
    it "should find commands defined in a more general context even when some state has been mutated" do
      shell_context do
        command 'ls /tmp/myfile' do
          stdout 'yes, your file exists'
        end

        command "rm /tmp/foobar" do
          stderr 1

          shell_context do
            command 'ls /tmp/foobar' do
              stdout 'the file no longer exists'
            end
          end
        end
      end

      `rm /tmp/foobar`
      `ls /tmp/myfile`.should == 'yes, your file exists'
    end
  end
end
