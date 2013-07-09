package org.tandrup.iphotoflickrsync

import groovy.sql.Sql

//this.getClass().classLoader.rootLoader.addURL(new File("sqlite-jdbc-3.7.2.jar").toURL());

def sql = Sql.newInstance( 'jdbc:sqlite:/Users/mtandrup/Pictures/iPhoto-bibliotek.photolibrary/Database/Faces.db',
	'org.sqlite.JDBC' )

sql.rows("SELECT fn.name, df.masteruuid FROM RKFaceName fn INNER JOIN RKDetectedFace df ON fn.facekey = df.facekey").each{
	println(it)
	}