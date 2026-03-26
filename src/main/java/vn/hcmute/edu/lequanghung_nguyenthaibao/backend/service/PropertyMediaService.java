package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PropertyMediaService {

    private final S3Service s3Service;

    public List<String> uploadImages(List<MultipartFile> images) {
        List<String> urls = new ArrayList<>();
        if (images != null) {
            for (MultipartFile file : images) {
                if (!file.isEmpty()) {
                    try {
                        urls.add(s3Service.uploadFile(file));
                    } catch (IOException e) {
                        throw new RuntimeException("Image upload failed", e);
                    }
                }
            }
        }
        return urls;
    }

    public String uploadVideo(MultipartFile video) {
        if (video != null && !video.isEmpty()) {
            try {
                return s3Service.uploadFile(video);
            } catch (IOException e) {
                throw new RuntimeException("Video upload failed", e);
            }
        }
        return null;
    }

    public void deleteMedias(List<String> urls) {
        if (urls != null) {
            for (String url : urls) {
                s3Service.deleteFile(url);
            }
        }
    }
}
