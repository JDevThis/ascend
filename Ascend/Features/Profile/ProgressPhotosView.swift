import SwiftUI
import PhotosUI
import UIKit

struct ProgressPhotosView: View {
    let viewModel: ProfileViewModel
    @State private var selectedAngle: PhotoAngle = .front
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var isComparing = false

    var body: some View {
        VStack(spacing: 0) {
            Picker("Angle", selection: $selectedAngle) {
                ForEach(PhotoAngle.allCases) { angle in
                    Text(angle.rawValue).tag(angle)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            let photos = viewModel.photos(for: selectedAngle)

            if photos.isEmpty {
                EmptyStateView(
                    systemImage: "photo.badge.plus",
                    title: "No \(selectedAngle.rawValue.lowercased()) photos",
                    message: "Add a photo to start your timeline."
                )
                Spacer()
            } else if isComparing, photos.count >= 2 {
                ComparisonSliderView(oldest: photos.last!, newest: photos.first!)
                    .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(photos) { photo in
                            if let uiImage = UIImage(data: photo.imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(3/4, contentMode: .fill)
                                    .frame(height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: AscendSpacing.controlCornerRadius))
                                    .overlay(alignment: .bottomLeading) {
                                        Text(photo.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.system(size: 10, weight: .semibold))
                                            .padding(4)
                                            .background(.black.opacity(0.6))
                                            .foregroundStyle(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                            .padding(4)
                                    }
                                    .contextMenu {
                                        Button("Delete", role: .destructive) {
                                            viewModel.deletePhoto(photo)
                                        }
                                    }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Progress Photos")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if viewModel.photos(for: selectedAngle).count >= 2 {
                    Button(isComparing ? "Grid" : "Compare") {
                        isComparing.toggle()
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                PhotosPicker(selection: $photoPickerItem, matching: .images) {
                    Image(systemName: "plus")
                }
            }
        }
        .onChange(of: photoPickerItem) { _, newItem in
            Task {
                if let newItem, let data = try? await newItem.loadTransferable(type: Data.self) {
                    viewModel.addPhoto(angle: selectedAngle, imageData: data)
                    photoPickerItem = nil
                }
            }
        }
    }
}

private struct ComparisonSliderView: View {
    let oldest: ProgressPhoto
    let newest: ProgressPhoto
    @State private var sliderPosition: CGFloat = 0.5

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                if let oldImage = UIImage(data: oldest.imageData) {
                    Image(uiImage: oldImage)
                        .resizable()
                        .aspectRatio(3/4, contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
                if let newImage = UIImage(data: newest.imageData) {
                    Image(uiImage: newImage)
                        .resizable()
                        .aspectRatio(3/4, contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .mask(alignment: .leading) {
                            Rectangle().frame(width: geometry.size.width * sliderPosition)
                        }
                }
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2)
                    .offset(x: geometry.size.width * sliderPosition)
                    .gesture(
                        DragGesture().onChanged { value in
                            sliderPosition = min(1, max(0, value.location.x / geometry.size.width))
                        }
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: AscendSpacing.cardCornerRadius))
        }
        .aspectRatio(3/4, contentMode: .fit)
    }
}
