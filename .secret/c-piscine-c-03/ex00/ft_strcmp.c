/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_strcmp.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: xcarroll <xcarroll@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/02/24 19:16:35 by xcarroll          #+#    #+#             */
/*   Updated: 2022/02/26 02:31:11 by xcarroll         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <unistd.h>

int	ft_strcmp(char *s1, char *s2)
{
	unsigned int	i;

	i = 0;
	while (s1[i] == s2[i] && (s1[i] != '\0' || s2[i] != '\0'))
	{
		i++;
	}
	return (s1[i] - s2[i]);
}

/*
#include <string.h>
#include <stdio.h>

int	main(void)
{
	char str1[] = "H";
	char str2[] = "Ho";
	printf("Original: %d\n", strcmp(str1, str2));
	printf("Mia: %d\n", ft_strcmp(str1, str2));
}
*/