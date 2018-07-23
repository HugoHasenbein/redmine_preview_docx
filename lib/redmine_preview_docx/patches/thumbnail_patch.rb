# encoding: utf-8
#
# Redmine plugin to preview a docx attachment file
#
# Copyright © 2018 Stephan Wenzel <stephan.wenzel@drwpatent.de>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

require 'pandoc-ruby'

module RedminePreviewDocx
  module Patches 
    module ThumbnailPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do

          unloadable 	
          
          # for those, who read and analyze code: I haven't figured it out yet how to unset 
          # a constant and how to patch a function, which has been defined as self.function()
          # in a base.class_eval block
          #
		  @REDMINE_PREVIEW_DOCX_CONVERT_BIN = ('pandoc').freeze
		  
		  # Generates a thumbnail for the source image to target
		  def self.generate_preview_docx(source, target, size)

			unless File.exists?(target)

			  directory = File.dirname(target)
			  unless File.exists?(directory)
				FileUtils.mkdir_p directory
			  end
			  
			  thumbnail_directory = File.join(Rails.root, "tmp", "thumbnails")
			  media_directory = File.basename(target, File.extname(target))
			                
			  cmd = "cd #{shell_quote thumbnail_directory}; #{shell_quote @REDMINE_PREVIEW_DOCX_CONVERT_BIN} -s #{shell_quote source} --extract-media=#{media_directory} -t html -o #{shell_quote target}"

 			  unless system(cmd)
				logger.error("Creating preview with pandoc failed (#{$?}):\nCommand: #{cmd}")
				return nil
			  end
			end
			target
		  end #def 
		                     
        end #base
      end #self

      module InstanceMethods          		  
      end #module
      
      module ClassMethods
      end #module
      
    end #module
  end #module
end #module

unless Redmine::Thumbnail.included_modules.include?(RedminePreviewDocx::Patches::ThumbnailPatch)
    Redmine::Thumbnail.send(:include, RedminePreviewDocx::Patches::ThumbnailPatch)
end


