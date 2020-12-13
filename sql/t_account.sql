/*
 Navicat Premium Data Transfer

 Source Server         : ju
 Source Server Type    : MySQL
 Source Server Version : 50722
 Source Host           : localhost:3306
 Source Schema         : seata_count

 Target Server Type    : MySQL
 Target Server Version : 50722
 File Encoding         : 65001

 Date: 08/12/2020 19:12:39
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for t_account
-- ----------------------------
DROP TABLE IF EXISTS `t_account`;
CREATE TABLE `t_account`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NULL DEFAULT NULL,
  `total` decimal(11, 0) NULL DEFAULT NULL,
  `used` decimal(11, 0) NULL DEFAULT NULL,
  `residue` decimal(10, 0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_account
-- ----------------------------
INSERT INTO `t_account` VALUES (1, 1, 100, 0, 100);

SET FOREIGN_KEY_CHECKS = 1;
