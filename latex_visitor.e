indexing
   description: "Convert AST to LaTex"
   author: "Julien LEMOINE <speedblue@debian.org>"
   --| Copyright (C) 2002 Julien LEMOINE
   --| This program is free software; you can redistribute it and/or modify
   --| it under the terms of the GNU General Public License as published by
   --| the Free Software Foundation; either version 2 of the License, or
   --| (at your option) any later version.
   --| 
   --| This program is distributed in the hope that it will be useful,
   --| but WITHOUT ANY WARRANTY; without even the implied warranty of
   --| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   --| GNU General Public License for more details.
   --|
   --| You should have received a copy of the GNU General Public License
   --| along with this program; if not, write to the Free Software
   --| Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 

class LATEX_VISITOR     


inherit DEFAULT_VISITOR
      rename
	 make as make_default
      redefine
	 sub_visit

creation
   make
	 
feature {ANY}
   make (a : AST; private : BOOLEAN; ppath, template_path : STRING) is
      do
	 make_default(a)
	 enable_private := private
	 path := ppath
	 !!str.make_empty
	 !!tglobal.make(template_path + TGLOBAL)
	 !!tdocument.make(template_path + TDOCUMENT)
	 !!tcomment.make(template_path + TCOMMENT)
      end
   
   get_result : STRING is
      do
	 tglobal.replace(DOCUMENTS, str)
	 Result := tglobal.stop
      end
   
feature {LATEX_VISITOR}
   sub_visit(doc : DOCUMENT) is
      local
	 i : INTEGER
      do
	 if (enable_private or doc.type.same_as(PUBLIQUE) or
	     doc.type.same_as(PUBLIC)) then
	    if (tdocument.start) then
	       tdocument.replace(TITREL, path + doc.file)
	       tdocument.replace(TITRE, doc.title)
	       tdocument.replace(AUTHORS, visit_strs(doc.authors))
	       tdocument.replace(DATE, doc.date)
	       tdocument.replace(LANGUAGE, doc.language)
	       tdocument.replace(TYPE, doc.type)
	       tdocument.replace(URL, doc.url)
	       tdocument.replace(SUMMARY, doc.summary)
	       tdocument.replace(PARTS, visit_strs(doc.parts))
	       tdocument.replace(COMMENTS, visit_cmts(doc.comments))
	       str.append(tdocument.stop)
	    end
	 end
      end
   
   visit_str (name : STRING) : STRING is
      do
	 if (name /= void) then
	    Result := name
	 else
	    Result := ""
	 end
      end
   
   visit_strs (strs : LINKED_LIST[STRING]) : STRING is
      local
	 i : INTEGER
      do
	 Result := ""
	 from i := 1 until i > strs.count loop
	    Result.append(visit_str(strs.item(i)))
	    i := i + 1
	    if (i <= strs.count) then
	       Result.append ("<br>")
	    end
	 end
      end
   
   visit_cmts (comments : LINKED_LIST[COMMENT]) : STRING is
      local
	 i : INTEGER
      do
	 Result := ""
	 if (comments /= void) then
	    from i := 1 until i > comments.count loop
	       Result.append(visit_cmt(comments.item(i)))
	       i := i + 1
	    end
	 end
      end

   visit_cmt (comment : COMMENT) : STRING is
      do   
	 Result := ""
	 if (comment /= void) then
	    if (tcomment.start) then
	       tcomment.replace(AUTHOR, comment.author_name)
	       tcomment.replace(CONTENT, comment.content)
	       Result.append(tcomment.stop)
	    end
	 end
      end
   
feature {LATEX_VISITOR}
   -- Public
   PUBLIC		: STRING is "public"
   PUBLIQUE		: STRING is "publique"
   
	 -- Strings to Replace 
   AUTHOR		: STRING is "%%%%AUTHOR%%"
   CONTENT		: STRING is "%%%%CONTENT%%"
   TITREL		: STRING is "%%%%TITREL%%"
   TITRE		: STRING is "%%%%TITRE%%"
   AUTHORS		: STRING is "%%%%AUTHORS%%"
   DATE			: STRING is "%%%%DATE%%"
   LANGUAGE		: STRING is "%%%%LANGUAGE%%"
   TYPE			: STRING is "%%%%TYPE%%"
   URL			: STRING is "%%%%URL%%"
   SUMMARY		: STRING is "%%%%SUMMARY%%"
   PARTS		: STRING is "%%%%PARTS%%"
   COMMENTS		: STRING is "%%%%COMMENTS%%"
   DOCUMENTS		: STRING is "%%%%DOCUMENTS%%"
   LINKS		: STRING is "%%%%LINKS%%"
   LINK			: STRING is "%%%%LINK%%"
   NUMBER		: STRING is "%%%%NUMBER%%"
	 
   -- Vars
   enable_private	: BOOLEAN
   path			: STRING
   str			: STRING
   tdocument		: TEMPLATE
   tglobal		: TEMPLATE
   tcomment		: TEMPLATE
   
   -- Templates Files
   TGLOBAL		: STRING is "/html/global.tpl"
   TDOCUMENT		: STRING is "/html/document.tpl"
   TCOMMENT		: STRING is "/html/comment.tpl"

end -- latex_vivitor
