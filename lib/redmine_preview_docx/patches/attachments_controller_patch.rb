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

module RedminePreviewDocx
  module Patches
    module AttachmentsControllerPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
            
          alias_method_chain     :show, :docx
         
          alias_method           :find_attachment_for_preview_docx, :find_attachment
          before_action          :find_attachment_for_preview_docx, :only => [:preview_docx]


		  def preview_docx

			if @attachment.is_docx? && preview = @attachment.preview_docx(:size => params[:size])

			  if stale?(:etag => preview)

				send_file preview,
				  :filename => filename_for_content_disposition( preview ),
				  :type => 'text/html',
				  :disposition => 'inline'
			  end
			else
			  # No thumbnail for the attachment or thumbnail could not be created
			  head 404
			end
		  end #def
 
		  def preview_docx_img
		  
		    dir1 = params[:dir1]
		    dir2 = params[:dir2]
		    img  = params[:img]
		    ext  = params[:format]
		    
		    img_file_path = File.join(Rails.root, "tmp", "thumbnails", dir1, dir2, img)
		    img_file_path += ".#{ext}"
		    
			mime_type = ""
			File.open(img_file_path) {|f| mime_type = MimeMagic.by_magic(f).try(:type) }
			thumbnail_filename   = File.basename(img, File.extname(img))
			thumbnail_filename  += Rack::Mime::MIME_TYPES.invert[mime_type] 
		    
			send_file img_file_path,
			  :filename => filename_for_content_disposition( thumbnail_filename ),
			  :type => mime_type,
			  :disposition => 'inline'
		    
 
          end #def

        end #base
        
      end #self

      module InstanceMethods

        def show_with_docx
          
          rendered = false
          respond_to do |format|
            format.html {
              if @attachment.is_docx?
                render :action => 'docx'
                rendered = true
              end
            }
            format.any {}
          end
          
          show_without_docx unless rendered 
        
        end #def 

      end #module  
      
      module ClassMethods      
      end #module    

    end #module
  end #module
end #module

unless AttachmentsController.included_modules.include?(RedminePreviewDocx::Patches::AttachmentsControllerPatch)
    AttachmentsController.send(:include, RedminePreviewDocx::Patches::AttachmentsControllerPatch)
end



