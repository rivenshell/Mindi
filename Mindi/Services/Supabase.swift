//
//  SupabaseManager.swift
//  Mindi
//
//  Created by Riv
//

import Foundation
import Supabase


let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://jgpkepahknmpllkttwbs.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpncGtlcGFoa25tcGxsa3R0d2JzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyMzUxNzksImV4cCI6MjA3ODgxMTE3OX0.oolTfBuaGwkdshgnGFUGktdW0cjo5QMXPHCRL_lce60"
)
