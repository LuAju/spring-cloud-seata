package com.ju.learn.service;


import feign.Param;

public interface StorageService {
    /**
     * 扣减库存
     */
    void decrease(@Param("productId") Long productId, @Param("count") Integer count);
}
