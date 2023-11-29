//
//  AccountsView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import SwiftUI


// SwiftUI view to display the list of news
struct NewsListView: View {
    @ObservedObject var viewModel = NewsViewModel()

    var body: some View {
        ZStack {
            Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
            VStack {
                Text("News")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: 400, maxHeight: 60)

        Spacer()
        NavigationView {
            List(viewModel.newsWithId, id: \.newId) { news in
                NavigationLink(destination: NewsDetailView(news: news)) {
                    NewsRowView(news: news)
                }
            }
        }
        .onAppear {
            viewModel.fetchNews()
        }
    }
}


// SwiftUI view for each news item in the list
struct NewsRowView: View {
    let news: NewWithId

    var body: some View {
        HStack(spacing: 16) {
            Image(news.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(news.headline)
                    .font(.headline)
                    .lineLimit(2)
                Text("By \(news.author) • \(news.date)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

// SwiftUI view for the detailed news view
struct NewsDetailView: View {
    let news: NewWithId

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image(news.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 200)
                    .cornerRadius(8)

                Text(news.headline)
                    .font(.title)
                    .fontWeight(.bold)

                Text("By \(news.author) • \(news.date)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(news.content)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
    }
}

