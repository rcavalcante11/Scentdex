//
//  ScentProfile.swift
//  Scentdex
//
//  Created by macbook on 27/03/2026.
//

import Foundation
import SwiftUI

struct ScentProfile {
    
    // MARK: - Properties
    let dominantFamily: FragranceFamily
    let secondFamily: FragranceFamily?
    let topNotes: [String]
    let familyDistribution: [FragranceFamily: Int]
    
    
    var profileTitle: String {
        if let second = secondFamily {
            return "\(dominantFamily.rawValue) & \(second.rawValue)"
        }
        return dominantFamily.rawValue
    }
    
    var profileDescription: String {
        switch (dominantFamily, secondFamily) {

        // WOODY
        case (.woody, .floral):
            return "Your collection balances structure with softness — you're drawn to fragrances that feel elegant without being delicate. The wood grounds the flowers and stops them from being too sweet or obvious. Perfumers call this Floral Woody, and it's one of the most refined territories in modern fragrance."
        case (.woody, .oriental):
            return "You build a collection for depth, not for first impressions. Your fragrances probably smell different on you than on anyone else — that's the resins and woods bonding with your skin. This accord is called Chypre Moderne, and it's been the signature of confident dressers for decades."
        case (.woody, .fresh):
            return "Your collection works everywhere — that's not an accident. You reach for fragrances that have backbone but never feel heavy, which is harder to achieve than it sounds. Perfumers call this Aromatic Woody, and it's the foundation of some of the most versatile fragrances ever made."
        case (.woody, .citrus):
            return "You like fragrances that start bright and settle into something warmer. The citrus opens things up, the wood keeps it grounded — it's a combination that rewards patience. What you're wearing on your skin an hour in is usually better than what you smelled in the bottle."
        case (.woody, .aquatic):
            return "Your collection has a quiet confidence to it — clean but not cold, structured but not heavy. The wood stops the aquatic notes from feeling too generic, which is the challenge with this family. It's a profile that says you know exactly what you like."
        case (.woody, .gourmand):
            return "Your collection sits in an unexpected but compelling place — warm woods meeting something almost edible. This combination feels intimate and skin-close rather than loud, which is precisely the point. It's a profile for people who wear fragrance for themselves first."
        case (.woody, .spicy):
            return "Your collection commands presence. The spice gives the woods an edge, creating fragrances that project with intention and leave a trail worth remembering. What perfumers call sillage — that trail you leave in a room — is probably something you think about."
        case (.woody, .herbal):
            return "Your collection has a natural, almost outdoors quality to it. The herbs give the woods a freshness that feels genuine rather than constructed. This is a Fougère-adjacent profile — one of the oldest and most respected traditions in fragrance."

        // FLORAL
        case (.floral, .woody):
            return "Your collection is built on one of the most successful accords in modern perfumery — but your version probably skews more sophisticated than most. The wood stops the flowers from being too soft, giving your collection a backbone that makes it memorable. Refined without trying to be."
        case (.floral, .oriental):
            return "Your collection sits in the Floriental — a territory that bridges romance and sensuality. These are fragrances that feel intimate and skin-close, meant to be discovered up close rather than announced from across the room. A deeply personal profile."
        case (.floral, .fresh):
            return "Your collection is approachable and confident in equal measure. Fresh florals are harder to get right than they seem — the best ones feel effortless without being forgettable. Your profile says you reach for fragrance as a finishing touch that completes, not competes."
        case (.floral, .citrus):
            return "Your collection opens with energy and settles into something softer. The citrus gives the florals a brightness that stops them from feeling too traditional. It's a combination that works well across seasons — light enough for warmth, elegant enough for everything else."
        case (.floral, .aquatic):
            return "Your collection leans clean and luminous. Aquatic florals capture something specific — the freshness of flowers after rain, or a garden near the sea. It's one of the more poetic profiles, and the best versions are genuinely transportive."
        case (.floral, .gourmand):
            return "Your collection blends bloom with warmth in the most enveloping way. Jasmine over vanilla, rose over praline — these are fragrances that feel like comfort. It's a profile for people who experience fragrance as something that wraps around them rather than walks ahead of them."
        case (.floral, .spicy):
            return "Your collection has an edge that most floral profiles don't. The spice stops the flowers from being predictable and adds a depth that makes your fragrances stand out. It's a combination that feels both feminine and fierce — never one without the other."
        case (.floral, .herbal):
            return "Your collection sits in a quietly sophisticated place — flowers grounded by herbs and green notes. It's a natural, almost botanical profile that feels considered rather than trend-driven. Wearers with this profile tend to have a strong personal relationship with what they choose to wear."

        // ORIENTAL
        case (.oriental, .woody):
            return "Your collection goes deep. Oud, amber, sandalwood and resins build fragrances of extraordinary richness and longevity — these are not casual choices. You probably think about what you're wearing before you reach for a bottle, and that intentionality shows."
        case (.oriental, .floral):
            return "Your collection sits in Floriental territory — warmth and bloom in conversation. The oriental base gives the florals a sensuality that lighter versions of this accord can't achieve. Fragrances that feel personal, intimate and completely yours."
        case (.oriental, .fresh):
            return "Your collection navigates a compelling contrast — warmth that still breathes. The fresh notes stop the oriental depth from becoming too heavy, making these fragrances surprisingly versatile. It's a profile that works in more contexts than most people expect."
        case (.oriental, .citrus):
            return "Your collection opens bright and settles into something rich — the full arc of what a great fragrance can do. The citrus top and oriental base create a contrast that rewards wearing through the day. What you smell in the first five minutes is just the beginning."
        case (.oriental, .aquatic):
            return "Your collection sits in an unusual and interesting place. Aquatic notes in an oriental context create something cooler and more restrained than a pure oriental — depth without heaviness. It's a sophisticated combination that not many people explore."
        case (.oriental, .gourmand):
            return "Your collection is built for intimacy. Warm, edible and deeply sensual, these fragrances feel like a second skin rather than a public statement. In niche perfumery, this is considered one of the most personal profiles you can have."
        case (.oriental, .spicy):
            return "Your collection is theatrical in the best sense. Saffron, cardamom and spice over resinous bases — fragrances of real depth and presence. This is a collector's profile, the kind of person who sees each bottle as a deliberate acquisition."
        case (.oriental, .herbal):
            return "Your collection blends ancient and modern in a way that feels entirely original. Herbs in an oriental context add a complexity that stops richness from becoming monotonous. It's an unexpected combination that signals a genuinely curious nose."

        // FRESH
        case (.fresh, .woody):
            return "Your collection has structure beneath the lightness. The wood gives fresh fragrances a backbone they often lack, turning them from simple to genuinely interesting. It's a profile built for versatility without sacrificing character."
        case (.fresh, .floral):
            return "Your collection is effortlessly wearable and genuinely elegant. Fresh florals at their best feel like clean skin with something beautiful just beneath the surface. Your profile says fragrance is a natural extension of who you are — never an effort."
        case (.fresh, .oriental):
            return "Your collection navigates a fascinating tension — lightness with depth underneath. The fresh notes make the oriental base approachable without losing any of its warmth. It's a combination that surprises people who assume they know what they're smelling."
        case (.fresh, .citrus):
            return "Your collection is built on clarity and energy. Aqua Fresh is one of the most universally wearable profiles in the wheel — and the best versions of it are deceptively simple. The sophistication is in the quality of what you choose, not the complexity."
        case (.fresh, .aquatic):
            return "Your collection breathes. Marine Fresh is a profile that evokes open air, coastlines and the outdoors — fragrance that feels like a place rather than just a scent. It's a clean profile worn by people who value how a fragrance makes them feel."
        case (.fresh, .gourmand):
            return "Your collection sits in an unexpected territory — clean and edible at once. Fresh gourmands are a relatively modern idea in perfumery, and the best ones feel like a contradiction that somehow works perfectly. An adventurous profile that not many people share."
        case (.fresh, .spicy):
            return "Your collection has a confidence that most fresh profiles lack. The spice adds an edge that stops these fragrances from being forgettable, making them sharper and more present than they first appear. It's a combination that grows on people."
        case (.fresh, .herbal):
            return "Your collection sits in classic Fougère territory — one of the oldest and most enduring traditions in fragrance. Lavender, herbs and fresh notes have been the foundation of refined grooming fragrance for over a century. A profile that values craft over novelty."

        // CITRUS
        case (.citrus, .woody):
            return "Your collection opens with energy and settles into something lasting. The wood stops citrus from being fleeting — which is the main challenge of this family — turning a bright opening into a full fragrance experience. Patience is rewarded here."
        case (.citrus, .floral):
            return "Your collection is bright and elegant in the same breath. Citrus florals feel like the first warm day — immediate, uplifting, effortlessly beautiful. It's a profile that works across almost every context, which is rarer than it sounds."
        case (.citrus, .oriental):
            return "Your collection covers the full range — from the brightest opening to the warmest base. The citrus top and oriental dry-down create the full arc of what great fragrance can do across a day. What you smell in the first minute is just the introduction."
        case (.citrus, .fresh):
            return "Your collection is defined by clarity and movement. Citrus and fresh notes together create fragrances that feel like clean air — immediate, transparent and energising. The best versions of this profile age beautifully as the top notes settle."
        case (.citrus, .aquatic):
            return "Your collection evokes somewhere specific — a coastline, a harbour, a warm afternoon near water. Citrus and aquatic notes together create something genuinely transportive. It's a profile worn by people who experience fragrance as atmosphere."
        case (.citrus, .gourmand):
            return "Your collection sits in an unexpected and interesting place — brightness meeting warmth and sweetness. Citrus gourmands are playful but never childish when done well. It's a combination that shows a willingness to explore beyond the obvious."
        case (.citrus, .spicy):
            return "Your collection has character beneath the brightness. The spice turns a simple citrus profile into something with real presence and edge. Fragrances that feel energetic and confident at the same time — harder to achieve than most people realise."
        case (.citrus, .herbal):
            return "Your collection is rooted in nature — bright herbs, zesty citrus, the outdoors translated into fragrance. This is an Aromatic profile with a long history in perfumery, associated with wearers who reach for fragrance as something grounding and real."

        // AQUATIC
        case (.aquatic, .woody):
            return "Your collection has depth beneath the clean surface. The wood stops aquatic fragrances from feeling too generic, giving them a structure that makes them genuinely interesting to wear through the day. A profile that knows what it wants."
        case (.aquatic, .floral):
            return "Your collection captures something specific and beautiful — flowers near water, luminous and clean. Aquatic florals at their best feel transportive rather than constructed. It's a profile that wears lightly but leaves an impression."
        case (.aquatic, .oriental):
            return "Your collection navigates a striking contrast — cool water meeting warm depth. This is an unusual combination that creates fragrances with real intrigue. Clean on the surface, rich underneath — the kind of profile that makes people ask what you're wearing."
        case (.aquatic, .fresh):
            return "Your collection breathes and moves. Marine Fresh is one of the most universally loved profiles — transparent, clean and effortless. The best versions feel like a place you want to return to, not just a scent you wear."
        case (.aquatic, .citrus):
            return "Your collection is all brightness and movement. Citrus and aquatic notes together evoke energy, open air and warm light on water. It's a profile that works instinctively — fragrances that feel like they belong rather than announce themselves."
        case (.aquatic, .gourmand):
            return "Your collection sits in a genuinely surprising place. Aquatic and gourmand notes don't meet often, and when they do it creates something completely unexpected — cool and warm, clean and indulgent simultaneously. A profile for the genuinely curious."
        case (.aquatic, .spicy):
            return "Your collection has an edge that most marine profiles lack. The spice adds intensity beneath the coolness, creating a contrast that feels modern and confident. It's a combination that stands out in a sea of straightforward aquatics."
        case (.aquatic, .herbal):
            return "Your collection is rooted in the natural world — sea air meeting herbs and green notes. This is a profile that feels genuine rather than constructed, associated with wearers who value fragrance that connects to something real."

        // GOURMAND
        case (.gourmand, .woody):
            return "Your collection is warm and grounded at once. The wood stops gourmand fragrances from being too sweet or one-dimensional, adding a seriousness that elevates the whole profile. These are fragrances that feel indulgent and refined in the same breath."
        case (.gourmand, .floral):
            return "Your collection wraps around you. Warm florals over sweet bases create fragrances that feel intimate and enveloping — worn for yourself as much as anyone else. It's one of the most personal profiles you can have."
        case (.gourmand, .oriental):
            return "Your collection is built for depth and intimacy. Gourmand oriental is considered one of the richest profiles in perfumery — tonka, vanilla, amber layered into fragrances that feel like a second skin. These stay with you long after the day ends."
        case (.gourmand, .fresh):
            return "Your collection sits in an interesting balance — sweetness made wearable by freshness. Gourmand fragrances with a fresh edge are modern, approachable and surprisingly versatile. It's a profile that works in more contexts than pure gourmand allows."
        case (.gourmand, .citrus):
            return "Your collection balances indulgence with brightness. The citrus lifts the sweetness and stops it from becoming heavy, creating fragrances that feel playful and easy. It's a profile that wears well across seasons."
        case (.gourmand, .aquatic):
            return "Your collection navigates an unusual territory — something warm and edible made clean by aquatic notes. This is a rare combination that creates fragrances of genuine surprise. A profile for someone who doesn't follow the obvious path."
        case (.gourmand, .spicy):
            return "Your collection is bold and indulgent without apology. Spiced gourmands — pepper over praline, cardamom over vanilla — are among the most memorable and distinctive fragrances in the wheel. This is a profile worn by people who leave an impression."
        case (.gourmand, .herbal):
            return "Your collection sits in an unexpected and interesting place. Herbs in a gourmand context add complexity and a natural quality that stops sweetness from dominating. It's a combination that shows a sophisticated relationship with what you wear."

        // SPICY
        case (.spicy, .woody):
            return "Your collection projects authority. Pepper and spice over dry woods create fragrances with exceptional backbone and presence — what perfumers call tenacity. These are not background fragrances. They arrive with you and stay long after you leave."
        case (.spicy, .floral):
            return "Your collection has an edge that most floral profiles lack. The spice adds intensity and character to the flowers, creating something that feels bold and feminine rather than soft and approachable. A profile that refuses to be ordinary."
        case (.spicy, .oriental):
            return "Your collection is the most opulent territory in the fragrance wheel. Saffron, oud and warm spices over resinous bases — fragrances of real depth and theatrical presence. This is a collector's profile. Each bottle is a deliberate choice."
        case (.spicy, .fresh):
            return "Your collection balances intensity with wearability. The fresh notes stop the spice from being too heavy, making these fragrances sharper and more versatile than they first appear. It's a surprising combination that works across more occasions than you'd expect."
        case (.spicy, .citrus):
            return "Your collection opens bright and lands hard. Citrus top notes with spicy depth create fragrances that cover the full arc — energetic, confident, memorable. The transition from the opening to the base is where the real character lives."
        case (.spicy, .aquatic):
            return "Your collection navigates a striking contrast — fire and water. Spice over aquatic notes creates something cool on the surface and intense underneath. It's a combination that generates real intrigue and stands out from almost everything else."
        case (.spicy, .gourmand):
            return "Your collection is warm, bold and completely unapologetic. Spiced gourmands layer pepper and cardamom over sweet, edible bases — fragrances of extraordinary depth and presence. It's a profile that leaves no room for being forgettable."
        case (.spicy, .herbal):
            return "Your collection sits in Aromatic Spicy territory — one of the most enduring traditions in masculine perfumery. Herbs and spices together create fragrances that feel natural and confident, rooted in decades of craft. A profile built on character."

        // HERBAL
        case (.herbal, .woody):
            return "Your collection is grounded and confident. Herbs over woods create an Aromatic profile with real backbone — fragrances that feel natural and considered rather than constructed. This is a profile associated with wearers who know exactly what they want."
        case (.herbal, .floral):
            return "Your collection sits in a quietly beautiful place — green herbs meeting bloom. It's a botanical profile that feels genuine and unconstructed, the fragrance equivalent of a garden in the morning. Worn by people who have a strong personal relationship with nature."
        case (.herbal, .oriental):
            return "Your collection blends tradition with richness in a genuinely original way. Herbs in an oriental context add a complexity that stops depth from becoming heavy. It's an unusual combination that signals a seriously curious nose — someone who's moved beyond the obvious."
        case (.herbal, .fresh):
            return "Your collection honours one of perfumery's oldest traditions. Fougère — lavender, herbs, fresh notes — has been the foundation of refined fragrance for over a century. It's a profile built on craft and longevity rather than trend."
        case (.herbal, .citrus):
            return "Your collection is rooted in the outdoors — bright citrus meeting aromatic herbs in a combination that feels genuinely natural. It's an energetic, clean profile with a long history in perfumery. Worn by people who reach for fragrance as something grounding."
        case (.herbal, .aquatic):
            return "Your collection captures the outdoors in a specific way — herbs and sea air, green and clean. It's a natural, unforced profile that feels like a landscape more than a construction. Wearers with this profile tend to have an instinctive relationship with what they wear."
        case (.herbal, .gourmand):
            return "Your collection sits in an unexpected place. Herbs grounding something sweet and warm — it's a combination that creates real intrigue. The herbal notes stop the gourmand from becoming indulgent, adding a seriousness that makes the whole profile more interesting."
        case (.herbal, .spicy):
            return "Your collection has intensity beneath the green surface. Spice adds depth and edge to aromatic herbs, creating fragrances with real presence and character. It's a combination that feels bold and natural at once — a profile that doesn't compromise."

        // SINGLE FAMILY — nil
        case (.woody, nil):
            return "Your collection is built on the backbone of perfumery itself. Woods have anchored fragrance for centuries, and a focused woody collection signals someone who values depth and longevity over novelty. You probably smell different wearing your fragrances than anyone else would."
        case (.floral, nil):
            return "Your collection focuses on floral excellence — the oldest and most celebrated territory in perfumery. Rather than chasing complexity, you gravitate toward fragrances that capture something beautiful with precision. A classical profile that never goes out of style."
        case (.oriental, nil):
            return "Your collection goes deep. Pure oriental profiles are built on warmth, resins and musks that last and evolve throughout the day. These are fragrances that reward wearing slowly — what you smell at the end of the day is often the best part."
        case (.fresh, nil):
            return "Your collection values clarity above all else. Fresh fragrances are harder to do well than they appear — the best ones feel effortless without being forgettable. Your profile says fragrance is always present, never overwhelming."
        case (.citrus, nil):
            return "Your collection is built on brightness and energy. Citrus fragrances are immediate and uplifting — the challenge is finding versions that last, and your collection suggests you've done the work. What opens sharp and bright is usually something worth staying with."
        case (.aquatic, nil):
            return "Your collection breathes. Marine fragrances capture open air and clean water — a feeling more than a scent. It's a universally wearable profile worn by people who value fragrance as atmosphere, something that shapes how they feel in a space."
        case (.gourmand, nil):
            return "Your collection leans warm and indulgent without apology. Pure gourmand profiles are increasingly sophisticated — far beyond simple sweetness into complex, edible compositions. It's one of the most personal profiles you can have, worn entirely for yourself."
        case (.spicy, nil):
            return "Your collection announces itself. Spicy profiles project with intention and leave a trail worth noticing — what perfumers call sillage. These are fragrances with strong character and real presence. A profile for people who wear fragrance as part of their identity."
        case (.herbal, nil):
            return "Your collection is rooted in one of perfumery's oldest and most enduring traditions. Fougère — lavender, geranium, coumarin — has been the foundation of refined grooming fragrance for over 150 years. A profile that values craft and longevity over trend."

        default:
            return "Your collection defies easy categorisation — and that's a mark of a genuine explorer. You move between fragrance families with curiosity rather than loyalty, building something that reflects real breadth of taste. The best nose in the room is always the most open one."
        }
    }

    var auraColors: [Color] {
        if let second = secondFamily {
            return [dominantFamily.color, second.color]
        }
        return [dominantFamily.color, dominantFamily.color.opacity(0.5)]
    }
    
    // MARK: - Factory
    static func calculate(from perfumes: [Perfume]) -> ScentProfile? {
        guard !perfumes.isEmpty else { return nil }

        // Count family frequency
        var familyCount: [FragranceFamily: Int] = [:]
        for perfume in perfumes {
            familyCount[perfume.family, default: 0] += 1
        }

        // Sort by frequency
        let sorted = familyCount.sorted { $0.value > $1.value }
        guard let dominant = sorted.first else { return nil }

        let second = sorted.count > 1 ? sorted[1].key : nil

        // Count note frequency
        var noteCount: [String: Int] = [:]
        for perfume in perfumes {
            for note in perfume.allNotes {
                noteCount[note.lowercased(), default: 0] += 1
            }
        }

        // Top 3 most frequent notes
        let topNotes = noteCount
            .sorted { $0.value > $1.value }
            .prefix(10)
            .map { $0.key.capitalized }

        return ScentProfile(
            dominantFamily: dominant.key,
            secondFamily: second,
            topNotes: topNotes,
            familyDistribution: familyCount
        )
    }
    
    
}
