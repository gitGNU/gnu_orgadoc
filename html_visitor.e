indexing
   description: "Convert AST to HTML"
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

class HTML_VISITOR     
   
inherit DEFAULT_VISITOR
      rename
	 make as make_default
      redefine
	 sub_visit

creation
   make
   
feature {ANY}
   make (a : AST;
	 output_path, file, ppath : STRING;
	 paths : LINKED_LIST[STRING];
	 nbs : LINKED_LIST[INTEGER];
	 template_path : STRING; params : PARAMS) is
      local
	 i	: INTEGER
	 tlink	: TEMPLATE
      do
	 !!cerr.make
	 make_default(a)
	 allow_private := params.enable_private
	 !!str.make_empty
	 !!tlink.make(template_path + CTLINK)
	 !!tglobal.make(template_path + CTGLOBAL)
	 !!tdocument.make(template_path + CTDOCUMENT)
	 !!tcomment.make(template_path + CTCOMMENT)
	 is_writable := tglobal.start
	 value := 0
	 if (is_writable) then
	    path := paths.item(1)
	    from i := 2 until i > paths.count loop
	       if tlink.start and (i - 1) <= nbs.count and 
		  nbs.item(i - 1) > 0 then
		  
		  tlink.replace(LINK, concat(output_path,
					     paths.item(i), 
					     ppath) + file);
		  tlink.replace(CONTENT, paths.item(i));
		  tlink.replace(NUMBER, nbs.item(i - 1).to_string);
		  str.append(tlink.stop)
	       end
	       i := i + 1
	    end
	    tglobal.replace(LINKS, str)
	    tglobal.replace(VERSION, params.get_version)
	 else
	    cerr.put_string ("Error : Could not load " +
			     template_path + CTGLOBAL + "%N")
	 end
	 !!str.make_empty
      end
   
   get_result : STRING is
      do
	 if (is_writable) then
	    tglobal.replace(DOCUMENTS, str)
	    Result := tglobal.stop
	 else
	    Result := ""
	 end
      end
   
   get_nb_docs : INTEGER is
      do
	 Result := value
      end
   
feature {HTML_VISITOR}
   concat (s1, s2, ppath : STRING) : STRING is
      local
	 new_s2 : STRING
	 i, max : INTEGER
      do
	 new_s2 := s2.substring(ppath.count + 1, s2.count)
	 if (s1.last = '/' and new_s2.first = '/') then
	    Result := s1 + new_s2.substring(2, new_s2.count)
	 else
	    Result := s1 + new_s2
	 end
	 max := 1
	 from i := 1 until i > Result.count loop
	    if (Result.item(i) = '/' and i /= Result.count) then
	       max := i
	    end
	    i := i + 1
	 end
	 if (max > 1) then
	    Result := "." + Result.substring(max, Result.count)
	 end
      end
   
   sub_visit (doc : DOCUMENT) is
      require
	 doc /= void
      do
	 if (allow_private or doc.type.same_as(PUBLIQUE) or
	     doc.type.same_as(PUBLIC)) then
	    if (tdocument.start) then
	       value := value + 1
	       if (path.substring(1, 2).same_as("./"))
		  tdocument.replace(TITREL, path.substring(2, path.count) 
				    + doc.file)
	       else
		  tdocument.replace(TITREL, path + doc.file)
	       end
	       tdocument.replace(TITRE, doc.title)
	       tdocument.replace(AUTHORS, visit_strs(doc.authors))
	       tdocument.replace(DATE, doc.date)
	       tdocument.replace(LANGUAGE, doc.language)
	       tdocument.replace(TYPE, doc.type)
	       tdocument.replace(URL, doc.url)
	       tdocument.replace(SUMMARY, doc.summary)
	       tdocument.replace(NBPAGES, doc.nbpages)
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
   
   visit_cmts (p_comments : LINKED_LIST[COMMENT]) : STRING is
      local
	 i : INTEGER
      do
	 Result := ""
	 if (p_comments /= void) then
	    from i := 1 until i > p_comments.count loop
	       Result.append(visit_cmt(p_comments.item(i)))
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
      
feature {HTML_VISITOR}
   str			: STRING
   header		: STRING
   path			: STRING
   allow_private	: BOOLEAN
   tcomment		: TEMPLATE
   tdocument		: TEMPLATE
   tglobal		: TEMPLATE
   
feature {HTML_VISITOR} -- Constants
   -- Global Template boolean
   is_writable		: BOOLEAN
   value		: INTEGER
   cerr			: STD_ERROR
   
   -- Template files
   CTLINK		: STRING is "/html/link.tpl"
   CTGLOBAL		: STRING is "/html/global.tpl"
   CTDOCUMENT		: STRING is "/html/document.tpl"
   CTCOMMENT		: STRING is "/html/comment.tpl"
   
   LOCALPATH		: STRING is "./"
end
