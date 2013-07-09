package org.tandrup.iphotoflickrsync

import groovy.sql.Sql

def faces = Sql.newInstance( 'jdbc:sqlite:/Users/mtandrup/Pictures/iPhoto-bibliotek.photolibrary/Database/Faces.db',
	'org.sqlite.JDBC' )

def library = Sql.newInstance( 'jdbc:sqlite:/Users/mtandrup/Pictures/iPhoto-bibliotek.photolibrary/Database/Library.apdb',
	'org.sqlite.JDBC' )

faces.rows("SELECT fn.name, df.masteruuid FROM RKFaceName fn INNER JOIN RKDetectedFace df ON fn.facekey = df.facekey").each{
	println(it);
	library.rows("SELECT imagePath FROM RKMaster WHERE uuid = '" + it.masterUuid + "'").each {
		println(it);
	}
}